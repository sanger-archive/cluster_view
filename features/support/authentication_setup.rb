# First we need to ensure that Factory Girl is working properly
require File.join(File.dirname(__FILE__), '..', '..', 'spec', 'support', 'authlogic_helper')
class Cucumber::Rails::World
  include Authlogic::FactoryGirl
end

# Then we need to make sure that there is a secure area of the site that we can always trigger
# a request for the user to login
class SiteController
  def secure
    render :text => 'Secure Area!'
  end
end
ActionController::Routing::Routes.add_named_route('secure', '/secure', :controller => 'site', :action => 'secure')

# Ensure that Authlogic is properly setup before each scenario and, if the scenario requires
# a user to be logged in, log a user in before those scenarios.  Because of the nature of
# webrat it seems that the login has to be done through the interaction with the application.
Before { activate_authlogic }

Before('@requires_user_to_be_logged_in') do
  Given 'the user "Default login user" is registered'
  When 'I attempt to login as "Default login user"'
  Then 'I should be logged in as "Default login user"'
end

Before { @batch_setup_functions = [] }
