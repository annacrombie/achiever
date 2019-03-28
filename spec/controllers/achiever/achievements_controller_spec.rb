RSpec.describe Achiever::AchievementsController do
  routes { Achiever::Engine.routes }

  it 'works' do
    get :index
    expect(response.content_type).to eq "text/html"
    expect(response.status).to eq(200)
  end

  it 'raises an error when you havent set the @achiever_subject ivar' do
    ApplicationController.skip_before_action :set_achiever_subject
    expect { get :index }.to raise_exception(
      Achiever::Exceptions::UninitializedAchieverSubject
    )
  end
end
