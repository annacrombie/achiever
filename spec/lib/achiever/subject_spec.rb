RSpec.describe Achiever::Subject do
  before(:each) do
    @user = User.create
  end

  it 'validates its includer' do
    k = Class.new
    expect {
      k.include(Achiever::Subject)
    }.to raise_exception(Achiever::Exceptions::InvalidSubject)
  end

  it 'can help you find achievements' do
    @user.achieve(:logins)
    expect(@user.achievement(:logins)).not_to be_nil
  end

  it 'can help you find if a user has a achievement' do
    expect(@user).not_to have_achievement(:logins)
    @user.achieve(:logins)
    expect(@user).to have_achievement(:logins)
  end

  it 'raises an exception on an invalid achievement name' do
    expect { @user.achieve(:acount_owner) }.to raise_exception(
      Achiever::Exceptions::InvalidAchievementName)
  end

  it 'raises an exception on an invalid slot name' do
    expect { @user.achieve(:profile, :feohifeh) }.to raise_exception(
      Achiever::Exceptions::InvalidSlot)
  end

  it 'raises an exception on an invalid type' do
    expect { @user.achieve(:profile, 1) }.to raise_exception(TypeError)
    expect { @user.achieve(:logins, :eoih) }.to raise_exception(TypeError)
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

    it 'can always get an achievement!' do
      [
        Thread.new do
          10.times.map do
            Thread.new do
              10.times do
                expect { @user.achievement!(:logins) }.not_to raise_exception
              end
            end
          end.map(&:join)
        end,
        Thread.new do
          10.times.map do
            Thread.new do
              10.times { @user.achievement!(:logins).delete }
            end
          end.map(&:join)
        end
      ].map(&:join)
    end
  end
end
