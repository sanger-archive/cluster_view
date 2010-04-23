module UserSessionsHelper
  def logged_in?
    not current_user.nil?
  end

  def using_systems_login?
    Settings.ldap_configuration?
  end

  def login_button_text
    l10n_key = using_systems_login? ? :login_with_systems_account : :login_without_systems_account
    translate("user_sessions.login.#{ l10n_key }")
  end

  def login_link_text
    translate('user_sessions.login.link_text')
  end

  def logout_link_text
    translate('user_sessions.logout.link_text')
  end
end
