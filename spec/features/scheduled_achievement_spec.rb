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

  it 'should also work with slotted achievements' do
    @user.achieve(:profile, :profile_picture, on: Date.today.next_month).tag!(:profile)

    expect(@user).not_to have_new_badges

    Timecop.travel(Date.today.next_year)

    expect(@user).to have_new_badges
    expect(@user.new_badges.first.name).to eq('Picture Perfect')
  end
end
