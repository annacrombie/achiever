RSpec.describe Achiever do
  it 'has a version' do
    expect(Achiever::VERSION).not_to be_nil
  end

  it 'can get you a badge' do
    expect(Achiever.badge(:profile, 2).name).to eq('Picture Perfect')
  end
end
