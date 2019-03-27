RSpec.describe Achiever::Helpers do
  before(:each) do
    @user = User.create
  end

  it 'awards slotted achievements' do
    @user.achieve(:profile, :profile_picture)

    expect(@user.badges.length).to eq(1)
    expect(@user.badges[0].attr[:name]).to eq('Picture Perfect')
  end

  it 'shows visible badges' do
    expect(@user.visible_badges.length).to eq(12)
  end
end
