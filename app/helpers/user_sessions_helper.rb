module UserSessionsHelper
  def logged_in?
    not current_user.nil?
  end
end
