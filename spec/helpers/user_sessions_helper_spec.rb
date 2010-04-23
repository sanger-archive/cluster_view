require 'spec_helper'

describe UserSessionsHelper do
  describe '#logged_in?' do
    after(:each) do
      helper.stub!(:current_user).and_return(@current_user)
      helper.logged_in?.should == @expected
    end

    it 'is true if the current user is non-nil' do
      @current_user, @expected = :current_user_is_logged_in, true
    end

    it 'is false if the current user is nil' do
      @current_user, @expected = nil, false
    end
  end

  describe '#using_systems_login?' do
    after(:each) do
      Settings.should_receive(:ldap_configuration?).and_return(@using_ldap)
      helper.using_systems_login?.should == @expected
    end

    it 'returns true if LDAP is being used' do
      @using_ldap = @expected = true
    end

    it 'returns false if LDAP is not being used' do
      @using_ldap = @expected = false
    end
  end

  describe '#login_button_text' do
    after(:each) do
      helper.should_receive(:using_systems_login?).and_return(@using_systems_account)
      helper.should_receive(:translate).with("user_sessions.login.#{ @key }").and_return(:ok)
      helper.login_button_text.should == :ok
    end

    it 'looks for the login with systems account message' do
      @using_systems_account, @key = true, :login_with_systems_account
    end

    it 'looks for the login without systems account message' do
      @using_systems_account, @key = false, :login_without_systems_account
    end
  end

  translation_method(:login_link_text, 'user_sessions.login.link_text')
  translation_method(:logout_link_text, 'user_sessions.logout.link_text')
end
