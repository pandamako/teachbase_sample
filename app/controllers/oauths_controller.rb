class OauthsController < ApplicationController
  skip_before_action :require_login

  def oauth
    login_at(params[:provider])
  end

  def callback
    provider = params[:provider]
    return_to = session['return_to_url']
    if @user = login_from(provider)
      redirect_to return_to || root_path, :notice => "Logged in from #{provider.titleize}!"
    else
      begin
        @user = create_from(provider)
        # NOTE: this is the place to add '@user.activate!' if you are using user_activation submodule

        reset_session # protect from session fixation attack
        auto_login(@user)
        redirect_to return_to || root_path, :notice => "Logged in from #{provider.titleize}!"
      rescue Exception => ex
        redirect_to root_path, :alert => "Failed to login from #{provider.titleize}!"
      end
    end
  end
end
