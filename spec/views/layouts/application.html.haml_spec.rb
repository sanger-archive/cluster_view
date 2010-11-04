require 'spec_helper'

layout_spec_for('application') do
  it 'has a link to the root page' do
    response.should have_link_to(root_path)
  end

  it 'has a link to the login page' do
    response.should have_link_to(login_path)
  end
  
  it_renders_flash_field(:message)
  it_renders_flash_field(:error)
  
  it 'has only one #flash element' do
    response.should have_tag('#flash', :count => 1)
  end
end

describe 'layout/application' do
  context 'when user logged in' do
    before(:each) do
      current_user = mock('Current User')
      current_user.stub(:username).and_return('CURRENT USER')
      @controller.stub(:current_user).and_return(current_user)
      render :text => 'CONTENT FOR RENDER', :layout => 'application'
    end

    it 'has a link to log out the current user' do
      response.should have_link_to(logout_path)
    end

    it 'has a form to search for batches' do
      response.should get_form_to(batch_search_path) do |form|
        form.should have_text_field(:name => 'id')
      end
    end
  end
end
