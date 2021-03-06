require 'sinatra/base'
require 'data_mapper'
require 'tilt/erb'
require 'rack-flash'
require 'bcrypt'
require 'sinatra/partial'
require './lib/controllers/applications'

env = ENV['RACK_ENV'] || 'development'

DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require './lib/link'
require './lib/tag'
require './lib/user'

DataMapper.finalize
DataMapper.auto_upgrade!

class BookmarkManager < Sinatra::Base

  configure do
    register Sinatra::Partial
  end

  enable :sessions
  set :session_secret, 'super secret'
  use Rack::Flash
  use Rack::MethodOverride

  helpers do

    def current_user
      @current_user ||= User.get(session[:user_id]) if session[:user_id]
    end

  end

  get '/' do
    @links = Link.all
    erb :homepage
  end

  post '/links' do
    url = params['url']
    title = params['title']
    tags = params['tags'].split(" ").map do |tag|
      Tag.first_or_create(text: tag)
    end
    Link.create(url: url, title: title, tags: tags)
    redirect to('/')
  end

  get '/tags/:text' do
    tag = Tag.first(text: params[:text])
    @links = tag ? tag.links : []
    erb :homepage
  end

  get '/users/new' do
    @user = User.new
    erb :'users/new'
  end

  post '/users' do
    @user = User.create(email: params['email'], password: params['password'], password_confirmation: params['password_confirmation'])
    if @user.save
      session[:user_id] = @user.id
      redirect to('/')
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :'users/new'
    end
  end

  get '/sessions/new' do
    erb :'sessions/new'
  end

  post '/sessions' do

    if params[:submit] == 'Sign in'
      email, password = params[:email], params[:password]
      user = User.authenticate(email, password)
      if user
        session[:user_id] = user.id
        redirect to('/')
      else
        flash[:errors] = ['The email or password is incorrect']
        erb :'sessions/new'
      end
    else
      email = params[:email]
      User.first(email: email).update(password_token: randon_token, password_token_timestamp: Time.now)
    end
  end

  def randon_token
    (1..64).map { ('A'..'Z').to_a.sample }.join
  end

  delete '/sessions' do
    session[:user_id] = nil
    flash[:notice] = 'Good bye!'
    redirect('/')
  end

  post '/sign_out' do
    'Good bye!'
  end

  # start the server if ruby file executed directly
  run! if app_file == BookmarkManager

end
