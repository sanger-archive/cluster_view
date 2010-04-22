require 'spec_helper'

class User
  public :ldap_authentication_details_for
  public :verify_ldap_credentials
end

describe User do
  before(:each) do
    @user = Factory('User: John Smith')
  end

  context '#verify_ldap_credentials' do
    before(:each) do
      Settings.instance.stub!(:ldap_configuration).and_return(:ldap => :details)
      @user.should_receive(:ldap_authentication_details_for).with('PASSWORD').and_return(:authentication => :details)

      @ldap = mock('LDAP session')
      Net::LDAP.should_receive(:new).with(
        :ldap => :details,
        :auth => { :method => :simple, :authentication => :details }
      ).and_return(@ldap)
    end

    after(:each) do
      @ldap.should_receive(:bind).and_return(@expected)
      @user.verify_ldap_credentials('PASSWORD').should == @expected
    end

    it 'returns true if the credentials are valid' do
      @expected = true
    end

    it 'returns false if the credentials are invalid' do
      @expected = false
    end
  end

  context '#ldap_authentication_details_for' do
    it 'returns authentication options for the given password' do
      @user.ldap_authentication_details_for('PASSWORD').should == { 
        :username => 'uid=John Smith,ou=people,dc=sanger,dc=ac,dc=uk',
        :password => 'PASSWORD'
      }
    end
  end
end
