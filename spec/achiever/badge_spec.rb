require 'rails_helper'

RSpec.describe Achiever::Badge do
  before(:each) do
    @badge = Achiever::Badge.new(:logins, 5, true)
  end

  it 'detects the right id' do
    expect(@badge.badge_id).to eq(1)
  end

  it 'loads the right cfg' do
    expect(@badge.cfg[:badges][1][:required]).to eq(5)
  end

  it 'knows its name' do
    expect(@badge.name).to eq('Regular')
  end

  it 'has a description' do
    expect(@badge.desc).to eq('Login 5 times')
  end

  it 'has an image' do
    expect(@badge.img).to eq('badge_regular')
  end

  it 'has is visible' do
    expect(@badge.visibility).to eq('visible')
  end

  it 'is achieved' do
    expect(@badge).to be_achieved
  end

  it 'has attributes' do
    expect(@badge.attr).to be_a(Hash)
  end
end
