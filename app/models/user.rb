class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.logged_in_timeout       = 2.weeks
    config.validate_password_field = false if Settings.ldap_configuration?
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
