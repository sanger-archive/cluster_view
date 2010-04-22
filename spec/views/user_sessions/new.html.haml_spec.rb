require 'spec_helper'

describe "/user_sessions/new" do
  before(:each) do
    assigns[ :user_session ] = UserSession.new
    render 'user_sessions/new'
  end

  with_a_form_for(:user_session) do
    it 'posts back to user session path' do
      response.should post_form_to(new_session_path)
    end

    it 'has a text field called "username"' do
      response.should have_text_field(:name => 'username')
    end

    it 'has a password field called "password"' do
      response.should have_password_field(:name => 'password')
    end

    it 'has a checkbox field called "remember_me"' do
      response.should have_checkbox_field(:name => 'remember_me')
    end
  end
end
