class SessionsController < ApplicationController

  def new
     @title = "Sign in"
  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      session[:maxscheduler] = user.maxscheduler_id
      sign_in user
      redirect_to user
      #redirect_to '/scheduler/showData'

    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    #redirect_to root_path
    #need to destory session object and clear cookies
    render 'new'
  end

  def current_maxscheduler_id
     current_user.maxscheduler_id
  end

end
