# Maintains information on a session that a User instance has: things like when they last logged
# in, etc.
class UserSession < Authlogic::Session::Base
  logout_on_timeout true
  generalize_credentials_error_messages true      # We shouldn't distinguish between errors

  # In the LDAP environment we defer to the LDAP system itself for logins.  This means that the
  # credential checking and the actual finding of the user is down to LDAP, not to us.
  if Settings.ldap_configuration?
    verify_password_method :verify_ldap_credentials 
    find_by_login_method   :find_by_ldap_username
  end
end
