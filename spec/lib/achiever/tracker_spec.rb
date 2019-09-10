RSpec.describe Achiever::Tracker do
  before { @user = User.create }
  let(:tracker) { make_tracker }

  context 'unit test' do
    it 'provides a default subject getter' do
      ki = tracker.new
      expect(ki).to respond_to(:subject)
      expect(ki.subject(1)).to eq(1)
    end

    it 'wont overwrite a preexisting subject method' do
      k = Class.new
      k.define_method(:subject) { |obj| false }
      k.include(Achiever::Tracker)
      ki = k.new
      expect(ki).to respond_to(:subject)
      expect(ki.subject(1)).to eq(false)
    end

    it 'adds a track class method' do
      expect(tracker).to respond_to(:track)

      tracker.track(:fef) { :fef }
      expect(tracker.tracking).to have_key('fef')

      tracker.track(new: :ff) { :ff }
      expect(tracker.tracking).to have_key('ff')
    end

    it 'ensures you use the right method' do
      tracker.track(wrong: :af) {}

      expect {
        tracker.new.before_save(fake_model(af: [1, 1]))
      }.to raise_exception(Achiever::Exceptions::InvalidTrackerMethod)
    end

    it 'sets arguments good' do
      q = Queue.new

      tracker.track(:zero)  { q.push([]) }
      tracker.track(:one)   { |a| q.push([a]) }
      tracker.track(:two)   { |a, b| q.push([a, b]) }
      tracker.track(:three) { |a, b, c| q.push([a, b, c]) }
      tracker.track(:four)  { |a, b, c, d| }
      ki = tracker.new

      obj =
        %i[zero one two three].map do |k|
          fake_model(k => [1, 2]).tap { |o| ki.before_save(o) }
        end

      expect(q.pop).to eq([])
      expect(q.pop).to eq([obj[1]])
      expect(q.pop).to eq([obj[2], 2])
      expect(q.pop).to eq([obj[3], obj[3], 2])

      expect {
        ki.before_save(fake_model(four: [1, 2]))
      }.to raise_exception(Achiever::Exceptions::TrackerArityTooLarge)
    end

    context 'methods' do
      it 'new' do
        q = Queue.new
        tracker.track(new: :a) { |a, b| q.push([a, b]) }
        obj = fake_model(a: [1, 2])
        tracker.new.before_save(obj)
        expect(q.pop).to eq([obj, 2])
      end

      it 'existence' do
        q = Queue.new
        tracker.track(existence: :a) { |a, b| q.push([a, b]) }
        obj = fake_model(a: [1, nil])
        tracker.new.before_save(obj)
        obj = fake_model(a: [1, 3])
        tracker.new.before_save(obj)
        expect(q.length).to eq(1)
        expect(q.pop).to eq([obj, 3])
      end

      it 'truthy' do
        q = Queue.new
        tracker.track(truthy: :a) { |a, b| q.push([a, b]) }
        obj = fake_model(a: [1, false])
        tracker.new.before_save(obj)
        obj = fake_model(a: [1, true])
        tracker.new.before_save(obj)
        expect(q.length).to eq(1)
        expect(q.pop).to eq([obj, true])
      end

      it 'both' do
        q = Queue.new
        tracker.track(both: :a) { |a, b| q.push([a, b]) }
        obj = fake_model(a: [1, 2])
        tracker.new.before_save(obj)
        expect(q.pop).to eq([obj, [1, 2]])
      end
    end
  end

  it 'actually works' do
    @user.update(age: 49)
    expect(@user).not_to have_achievement(:get_older)
    @user.update(age: 51)
    expect(@user).to have_achievement(:get_older)
  end
end
