require 'rails_helper'

RSpec.describe 'achiever/achievements/index.html.erb' do
  before(:all) do
    @achievements = User.new.visible_badges
    @progress = @achievements.keys.map { |k| [k, [1, 1]] }.to_h
  end

  it 'renders' do
    render
    expect(rendered).to match(/#{I18n.t('achiever.my_badges')}/)
  end
end
