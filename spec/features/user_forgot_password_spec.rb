
feature 'User has forgoten password' do

  before(:each) do
    User.create(email: 'test@test.com',
                password: 'test',
                password_confirmation: 'test')
  end

  scenario 'user request to recover password' do
    visit '/sessions/new'
    fill_in :email, with: 'test@test.com'
    click_button 'Forgot password'
    expect(User.first(email: 'test@test.com').password_token).not_to eq nil
    expect(User.first(email: 'test@test.com').password_token_timestamp).not_to eq nil
  end

  scenario 'server generates randon password token and timestamp' do

  end

  def randon_token
    (1..64).map { ('A'..'Z').to_a.sample }.join
  end

end
