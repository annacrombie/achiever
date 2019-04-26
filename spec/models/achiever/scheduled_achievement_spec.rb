RSpec.describe Achiever::ScheduledAchievement do
  before do
    @user = User.create
    10.times do |i|
      @user.achieve(:logins, on: Date.tomorrow + i).tag!('test', "d#{i}")
    end

    10.times do |i|
      @user.achieve(:phishing, on: Date.tomorrow + i).tag!('test', 'phishing', "d#{i}")
    end
  end

  after do
    @user.scheduled_achievements.cancel_all
  end

  it 'can be gotten from the scheduled_achievements method' do
    expect(@user.scheduled_achievements.count).to eq(20)
  end

  it 'can be accessed via a tagged scope' do
    expect(@user.scheduled_achievements.tagged('test').length).to eq(20)
    expect(@user.scheduled_achievements.tagged(:test, :phishing).length).to eq(10)
    expect(@user.scheduled_achievements.tagged(:phishing).length).to eq(10)
    expect(@user.scheduled_achievements.tagged(:d2).length).to eq(2)
    expect(@user.scheduled_achievements.tagged(:d2, :test).length).to eq(2)
  end
end
