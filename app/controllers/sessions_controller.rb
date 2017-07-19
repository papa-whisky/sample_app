class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)

    if @user.try(:authenticate, params[:session][:password])
      @user.activated? ? create_session : flash_not_activated
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def create_session
    log_in @user
    params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
    redirect_back_or @user
  end

  def flash_not_activated
    flash[:warning] = 'Account not activated. Check you email for the ' \
      'activation link.'
    redirect_to root_url
  end
end
