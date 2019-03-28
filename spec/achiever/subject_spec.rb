RSpec.describe Achiever::Subject do
  before(:each) do
    @user = User.create
  end

  it 'can help you find achievements' do
    @user.achieve(:logins)
    expect(@user.achievement(:logins)).not_to be_nil
  end

  it 'shows visible badges' do
    expect(@user.visible_badges.length).to eq(12)
    @user.achieve(:account_owner)
    expect(@user.visible_badges.length).to eq(13)
  end

  it 'raises an exception on an invalid achievement name' do
    expect { @user.achieve(:acount_owner) }.to raise_exception(
      Achiever::Exceptions::InvalidAchievementName)
  end

  it 'raises an exception on an invalid slot name' do
    expect { @user.achieve(:profile, :feohifeh) }.to raise_exception(
      Achiever::Exceptions::InvalidSlot)
  end

  context '#achieve' do
    it 'will create achievements for you' do
      expect(@user.achievement(:logins)).to be_nil
      @user.achieve(:logins)
      expect(@user.achievement(:logins)).not_to be_nil
    end

    it 'will only create one per name' do
      expect(@user.achievement(:logins)).to be_nil
      @user.achieve(:logins)
      @user.achieve(:logins)
      expect(@user.achievements.where(name: :logins).count).to eq(1)
    end

    it 'awards slotted achievements' do
      @user.achieve(:profile, :profile_picture)

      expect(@user.badges.length).to eq(1)
      expect(@user.badges[:profile].first.name).to eq('Picture Perfect')
    end

    it 'can notify you' do
      @user.achieve(:profile, :profile_picture)
      expect(@user).to have_new_badges
      expect(@user.new_badges[0].name).to eq('Picture Perfect')
      @user.clear_new_badges
      expect(@user).not_to have_new_badges

      @user.achieve(:logins, 1)
      expect(@user).to have_new_badges
      expect(@user.new_badges[0].name).to eq('Roll Call')
      @user.clear_new_badges
      expect(@user).not_to have_new_badges

      expect(@user.badges.length).to eq(2)
    end
  end
end
