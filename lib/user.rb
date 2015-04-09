require 'bcrypt'
class User

  attr_reader :password
  attr_accessor :password_confirmation

  include DataMapper::Resource

  validates_confirmation_of :password

  property :id,       Serial
  property :email,    String, unique: true, message: 'This email is already taken'
  property :password_digest, Text

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def self.authenticate(email, password)
    user = first(email: email)
    user if user && BCrypt::Password.new(user.password_digest) == password
  end

end
