RSpec.describe 'scheduling achievements' do
  before do
    Timecop.freeze(Date.today)

    @user = User.create
  end

  after do
    Timecop.return

    @user.destroy
  end

  it 'should let you schedule achievements' do
    @user.achieve(:phishing, 2, on: Date.tomorrow).tag!(:p1)

    expect(@user).not_to have_new_badges

    Timecop.travel(Date.tomorrow)

    expect(@user).to have_new_badges
    expect(@user.achievement(:phishing).scheduled_achievements).to be_empty
  end
end
