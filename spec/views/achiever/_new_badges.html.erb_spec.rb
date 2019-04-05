require 'rails_helper'

RSpec.describe 'achiever/_new_badges.html.erb' do
  before(:all) do
    @user = User.create
    @user.achieve(:coins, 100000)
  end

  after(:all) do
    @user.destroy
  end

  it 'raises an exception if you forgot to pass subject' do
    expect { render 'achiever/new_badges' }.to raise_exception(
      ActionView::Template::Error
    )
  end

  it 'renders' do
    render 'achiever/new_badges', subject: @user
    expect(rendered).not_to match('missing_translation')
    expect(rendered).to match(/#{I18n.t('achiever.messages.new_badges')}/)
  end
end
