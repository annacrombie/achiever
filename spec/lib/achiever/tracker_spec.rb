RSpec.describe Achiever::Tracker do
  before { @user = User.create }

  it 'tracks achievements' do
    @user.update(age: 49)
    expect(@user).not_to have_achievement(:get_older)
    @user.update(age: 51)
    expect(@user).to have_achievement(:get_older)
  end
end
