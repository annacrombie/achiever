RSpec.describe 'real world achievements' do
  before { @user = User.create }
  after { @user.destroy }

  %i[logins courses risk_quiz course_groups].each do |cm|
    it "works with #{cm}" do
      n = (10 * rand).round + 3
      n.times { @user.achieve(cm) }
      expect(@user.achievements.find_by(name: cm).progress).to eq(n)
    end
  end
end
