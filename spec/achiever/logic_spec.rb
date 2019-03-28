RSpec.describe Achiever::Logic do
  it 'can determine attained achievements' do
    expect(Achiever::Logic.attained?(:logins, 1, 1)).to eq(true)
    expect(Achiever::Logic.attained?(:logins, 5, 1)).to eq(false)

    expect(Achiever::Logic.attained?(:profile, 8, 16)).to eq(false)
    expect(Achiever::Logic.attained?(:profile, 8, 15)).to eq(true)
  end

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

  it 'can progress slots' do
    expect(Achiever::Logic.slotted_progress(0, %i[a b], :a)).to eq(2)
    expect(Achiever::Logic.slotted_progress(2, %i[a b], :a)).to eq(2)
    expect(Achiever::Logic.slotted_progress(4, %i[a b], :a)).to eq(6)
    expect(Achiever::Logic.slotted_progress(6, %i[a b], :a)).to eq(6)
    expect(Achiever::Logic.slotted_progress(2, %i[a b], :b)).to eq(6)
    expect(Achiever::Logic.slotted_progress(4, %i[a b], :b)).to eq(4)
  end

  it 'can progress accumulation' do
    expect(Achiever::Logic.cumulative_progress(4, 1)).to eq(5)
  end

  it 'can calculcate overall progress' do
    expect(Achiever::Logic.overall_progress(:leaderboard, 2)).to eq([1, 3])
    expect(Achiever::Logic.overall_progress(:logins, 1)).to eq([1, 30])
  end
end
