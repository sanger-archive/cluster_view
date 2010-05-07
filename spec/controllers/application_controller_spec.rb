require 'spec_helper'

ApplicationController  # Force Hudson environment to load the class before we alter it
class ApplicationController
  public :current_user_session
  public :current_user
end

describe ApplicationController do
  describe '#current_user_session' do
    after(:each) do
      @controller.current_user_session.should == :current_session
    end

    it 'returns the user session instance variable if it is set' do
      @controller.instance_variable_set('@current_user_session', :current_session)
    end

    it 'returns the user session from the store' do
      UserSession.stub!(:find).and_return(:current_session)
    end
  end

  describe '#current_user' do
    it 'returns the user instance variable if it is set' do
      @controller.instance_variable_set('@current_user', :current_user)
      @controller.current_user.should == :current_user
    end

    it 'returns nil if there is no current user session' do
      @controller.stub!(:current_user_session).and_return(nil)
      @controller.current_user.should be_nil
    end

    it 'returns the user of the current user session' do
      current_session = mock('current user session')
      current_session.stub!(:user).and_return(:current_user)
      @controller.stub!(:current_user_session).and_return(current_session)
      @controller.current_user.should == :current_user
    end
  end
end
