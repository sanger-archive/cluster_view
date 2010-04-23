# The authentication part of the application, managing the UserSession instances that are currently
# in progress.
class UserSessionsController < ApplicationController
  before_filter :require_user,    :only => :destroy
  
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = translate('user_sessions.login.success')
      redirect_back_or_root
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.try(:destroy)
    flash[:notice] = translate('user_sessions.logout.success')
    redirect_back_or_root
  end
end
