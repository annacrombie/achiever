RSpec.describe Achiever::Logic do
  it 'can convert a slots to an integer' do
    expect(Achiever::Logic.slots_to_required(%i[a b], %i[a])).to eq(2)
    expect(Achiever::Logic.slots_to_required(%i[a b], %i[b])).to eq(4)
    expect(Achiever::Logic.slots_to_required(%i[a b], %i[a b])).to eq(6)
  end

  it 'can convert one slot to an integer' do
    expect(Achiever::Logic.slot_to_progress(%i[a b], :a)).to eq(2)
    expect(Achiever::Logic.slot_to_progress(%i[a b], :b)).to eq(4)
  end

  it 'can go in the opposite direction' do
    expect(Achiever::Logic.progress_to_slot_indices(6)).to eq([0, 1])
    expect(Achiever::Logic.progress_to_slot_indices(8)).to eq([2])
    expect(Achiever::Logic.progress_to_slot_indices(0)).to eq([])
  end
end
