RSpec.describe Achiever::Types do
  it 'assigns the right type' do
    expect(Achiever::Types.mod('cumulative')).to eq(Achiever::Types::Cumulative)
    expect(Achiever::Types.mod('slotted')).to eq(Achiever::Types::Slotted)
  end
end

RSpec.describe Achiever::Types::Base do
  before(:each) do
    @klass = Class.new
    @klass.include(Achiever::Types::Base)
  end

  it 'raises an exception for every method' do
    expect {
      @klass.new.achieve(:logins, 1)
    }.to raise_exception(NotImplementedError)
  end
end
