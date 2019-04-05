require 'rails_helper'

RSpec.describe 'achiever/_badge.html.erb' do
  it 'raises an exception if you forgot to pass badge' do
    expect { render 'achiever/badge' }.to raise_exception(
      ActionView::Template::Error
    )
  end
end
