class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      if @user.activated?
        log_in @user
        # if remember me ? saves cookie
        # else logs the user out of all systems, and uses session based authentication for current session
        params[:session][:remember_me] == "1" ? remember(@user) : forget(@user)
        redirect_back_or @user  # alternatively: redirect_to user_url(@user)
      else
        message = "Account not activated. Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = "Invalid email/password combination" # Not quite right!
      render "new"
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
