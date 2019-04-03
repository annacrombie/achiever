class NewBadgesTestController < ApplicationController
  def index
    @user = User.create
    @user.achieve(:logins, 1)
    @user.achieve(:phishing, 1)
    render
    @user.destroy
  end
end
