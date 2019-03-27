RSpec.describe Achiever do
  context Achiever::Config do
    it 'adds in default values' do
      expect(Achiever.achievement(:logins)[:visibility]).to eq('visible')
    end
  end

  context 'gettin achievements' do
    before(:each) do
      @user = User.create
    end

    it 'awards slotted achievements' do
      @user.achieve(:profile, :profile_picture)

      expect(@user.badges.length).to eq(1)
      expect(@user.badges[0].attr[:name]).to eq('Picture Perfect')
    end
  end
end
