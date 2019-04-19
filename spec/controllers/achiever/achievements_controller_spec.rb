RSpec.describe Achiever::AchievementsController do
  routes { Achiever::Engine.routes }

  it 'works' do
    get :index
    expect(response.content_type).to eq "text/html"
    expect(response.status).to eq(200)
  end
end
