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

  context 'visibility' do
    context 'hidden' do
      let(:ach) { Achiever::Achievement.new(name: :account_owner, subject_id: @user.id) }

      it 'won\'t be displayed' do
        expect(ach).not_to be_visible
      end
    end

    context 'custom' do
      it 'handles custom behavior' do
        Achiever.subject = User
        user = User.create(age: 1)
        ach = Achiever::Achievement.new(name: :get_older, subject_id: user.id)
        ach.subject = user

        expect(ach).not_to be_visible
        user.age = 26
        expect(ach).to be_visible
      end
    end
  end
end
