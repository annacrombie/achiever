require 'rails_helper'

RSpec.describe Achiever::Achievement do
  before(:each) do
    @user = User.create
  end

  after(:each) do
    @user.destroy
  end

  it 'can get all of its badges' do
    @user.achieve(:logins, 0)
    ach = @user.achievements.first
    expect(ach.badges.length).to eq(4)
  end

  it 'invalidates multiple achievements of the same name for the same user' do
    @user.achieve(:logins, 0)
    ach = Achiever::Achievement.new(name: :logins, subject_id: @user.id)
    expect(ach).not_to be_valid
  end
end
