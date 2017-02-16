class UserSessionsController < ApplicationController
  def new

  end

  def destroy
    logout
    redirect_to :users, notice: 'Logged out!'
  end
end
