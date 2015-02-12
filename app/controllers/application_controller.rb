# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  class << self

    alias_method :filter_parameter_logging_without_form_vars, :filter_parameter_logging

    def filter_parameter_logging(*filter_words, &block)
      filter_parameter_logging_without_form_vars(*filter_words) do |key, value|
        # Rails 2.3 can't split the 'rack.request.form_vars' env into sub
        # string. So it doesn't filter the password. We need to do it ourselves
        # in a block.
        block.call(key,value) if block.present?
        filter_words.each do |word|
          rex= Regexp.new("&([^&]*)(#{word})(%5D){0,1}=[^&]*")
          value.gsub!(rex,'&\1\2\3=[FILTERED]')
        end if key == 'rack.request.form_vars'
      end
    end
  end

  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user

private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session.try(:user)
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = translate('user_sessions.require_login')
      redirect_to login_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_root
    redirect_back_or_default(root_path)
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
