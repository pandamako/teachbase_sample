class UserSessionsController < ApplicationController
  def new

  end

  def destroy
    logout
    redirect_to root_url, notice: 'Logged out!'
  end
end
