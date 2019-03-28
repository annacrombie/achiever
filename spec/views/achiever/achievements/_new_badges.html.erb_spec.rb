require 'rails_helper'

RSpec.describe 'achiever/_new_badges.html.erb' do
  before(:all) do
    @user = User.create
    @user.achieve(:coins, 100000)
  end

  after(:all) do
    @user.destroy
  end

  it 'renders' do
    render 'achiever/new_badges.html.erb', subject: @user
    expect(rendered).not_to match('missing_translation')
    expect(rendered).to match(/#{I18n.t('achiever.congratulations', name: 'Richie Rich')}/)
  end
end
