# In order to use the system people have to be registered users and each one becomes an instance of
# this class.
class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.logged_in_timeout       = 2.weeks
    config.validate_password_field = false if Settings.ldap_configuration?
  end

  # In the LDAP environment we're going to assume that the username exists and create an instance
  # for the specified username.  Unfortunately this does mean that if someone decides to tries thousands
  # of usernames in order to break in we'll start populating the database with them, which could lead to
  # its own issues.  But for now we'll assume this is ok.
  def self.find_by_ldap_username(username)
    user = User.find_by_username(username)
    if user.nil?
      # NOTE[md12]: For some reason AuthLogic requires the persistence_token to be set to something other
      # than blank for the User instance to be able to login. So we force that here, even though it shouldn't
      # be an issue.
      user = User.new(:username => username)
      user.reset_persistence_token!
    end
    user
  end

protected
  
  def verify_ldap_credentials(password_in_plaintext)
    ldap_configuration = Settings.ldap_configuration
    ldap_configuration[ :auth ] ||= { :method => :simple }
    ldap_configuration[ :auth ].merge!(ldap_authentication_details_for(password_in_plaintext))

    Net::LDAP.new(ldap_configuration.symbolize_keys).bind
  end

private

  def ldap_authentication_details_for(password_in_plaintext)
    { :username => "uid=#{ self.username },ou=people,dc=sanger,dc=ac,dc=uk", :password => password_in_plaintext }
  end

end
