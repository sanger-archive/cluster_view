#########################################################################################################
#########################################################################################################
Given /^there are no registered users$/ do
  User.destroy_all
end

Given /^I am not logged in$/ do
  session = UserSession.find
  session.destroy unless session.nil?
end

Given /^the user "([^\"]+)" is registered$/ do |username|
  User.find_by_username(username) || Factory("User: #{ username }", :log_out => true)
end

Given /^I am logged in as "([^\"]+)"$/ do |username|
  When %Q{I attempt to login as "#{ username }"}
end

Given /^I logged in as "([^\"]+)" (\d+) (second|minute|hour|day|week|month|year)s? ago$/ do |username, value, period|
  When %Q{I attempt to login as "#{ username }"}
  UserSession.find.should_not be_nil
  UserSession.find.record.update_attribute(:last_request_at, value.to_i.send(period).ago)
end

#########################################################################################################
#########################################################################################################
When /^I attempt to login as "([^\"]+)"$/ do |username|
  When %Q{I attempt to login as "#{ username }" with password "#{ username }"}
end

When /^I attempt to login as "([^\"]+)" with password "([^\"]+)"$/ do |username, password|
  Given 'I am on the login page'
  When %Q{I fill in "user_session[username]" with "#{ username }"}
  When %Q{I fill in "user_session[password]" with "#{ password }"}
  When 'I press "Login"'
end

When /^I logout$/ do
  Given 'I am on the logout page'
end

When /^I visit a secure area of the application$/ do
  Given 'I am on a secure page'
end

#########################################################################################################
#########################################################################################################
Then /^I should not be logged in$/ do
  UserSession.find.should be_nil
end

Then /^I should see an authentication error$/ do
  Then 'I should see "prohibited this user session from being saved" within "#errorExplanation"'
end

Then /^I should be logged in as "([^"]+)"$/ do |username|
  UserSession.find.should_not be_nil
  UserSession.find.record.should == User.find_by_username(username)
end

Then /^I should( not)? be challenged to log in$/ do |not_assertion|
  Then "I should#{ not_assertion } be on the login page"
end
