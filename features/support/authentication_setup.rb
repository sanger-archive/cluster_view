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

# Finally we ensure that AuthLogic is always setup correctly for each scenario.
Before { activate_authlogic }
