require 'spec_helper'

describe UserSessionsHelper do
  context '#logged_in?' do
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
end
