class UserSession < Authlogic::Session::Base
  logout_on_timeout true
  verify_password_method :verify_ldap_credentials if Settings.ldap_configuration?
end
