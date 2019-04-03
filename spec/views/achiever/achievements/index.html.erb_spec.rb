require 'rails_helper'

RSpec.describe 'achiever/achievements/index.html.erb' do
  before(:all) do
    @achievements = [
      {
        name: :logins,
        prog: [1, 1],
        badges: [Achiever::Badge.new(:logins, 5, true)]
      }
    ]
  end

  it 'renders' do
    render
    expect(rendered).to match(/#{I18n.t('achiever.messages.my_badges')}/)
    expect(rendered).not_to match(/missing\.translation/i)
  end
end
