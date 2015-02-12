require 'spec_helper'

describe UserSessionsController do
  check_routing do
    routing_to('/new_session', { :action => 'create' }, RoutingHelper::HTTP_POST_ONLY)
    routing_to('/login', { :action => 'new' }, RoutingHelper::HTTP_GET_ONLY)
    routing_to('/logout', { :action => 'destroy' }, RoutingHelper::HTTP_GET_ONLY)
  end

  describe "GET 'new'" do
    before(:each) do
      get 'new'
    end

    it 'renders the login page' do
      response.should be_success
    end

    it 'assigns user_session for the view' do
      assigns[ :user_session ].should_not be_nil
    end
  end

  describe "POST 'create'" do
    before(:each) do
      @user = Factory('User: John Smith', :log_out => true)
    end

    context 'with an invalid login' do
      after(:each) do
        post 'create', 'user_session' => @login_params
        response.should be_success
        session_should_not_be_logged_in
      end

      it 'fails to login with no user_session details' do
        @login_params = { }
      end

      it 'fails to login if the user name does not match' do
        @login_params = { 'username' => @user.username, 'password' => @user.username.reverse }
      end
    end

    context 'with a valid login' do
      before(:each) do
        @controller.should_receive(:translate).with('user_sessions.login.success').and_return('success')
        post 'create', 'user_session' => { 'username' => @user.username, 'password' => @user.username }
      end

      after(:each) do
        flash[ :notice ].should == 'success'
      end

      it 'redirects to the root of the application' do
        response.should redirect_to(root_path)
      end

      it 'logs the user in' do
        session_should_be_logged_in_as(@user)
      end
    end

    context 'in any circumstances' do
      it 'filters password from all lparameters' do
        assert_equal(
          {"rack.request.form_vars"=>"authenticity_token=xxxxx&user_session%5Busername%5D=test&user_session%5Bpassword%5D=[FILTERED]&user_session%5Bremember_me%5D=0&commit=Login"},
          @controller.__send__(:filter_parameters,{"rack.request.form_vars"=>"authenticity_token=xxxxx&user_session%5Busername%5D=test&user_session%5Bpassword%5D=secret&user_session%5Bremember_me%5D=0&commit=Login"})
          )
      end
    end
  end

  describe "GET 'destroy'" do
    context 'when logged in' do
      before(:each) do
        @controller.should_receive(:translate).with('user_sessions.logout.success').and_return('success')

        Factory('User: John Smith')
        get 'destroy'
      end

      after(:each) do
        flash[ :notice ].should == 'success'
      end

      it 'redirects to the login page' do
        response.should redirect_to(root_path)
      end

      it 'logs the current user out' do
        session_should_not_be_logged_in
      end
    end

    context 'when not logged in' do
      before(:each) do
        get 'destroy'
      end

      it 'redirects to the login page' do
        response.should redirect_to(login_path)
      end
    end
  end
end
