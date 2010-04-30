@requires_user_to_be_logged_in
Feature: Batch search
  In order to find a particular batch
  As a user
  I want to pass a batch number
	And be presented with the corresponding batch

	Scenario: Search a valid batch ID
	  Given I am on the batch search page
	  And batch ID "1044" is valid
	  When I search for batch ID "1044" 
	  Then I should see "Batch ID: 1044"
	
	Scenario: Search for batch that doesn't exit
	  Given I am on the batch search page
	  And batch ID "2" is invalid
	  When I search for batch ID "2"
	  Then I should see "Batch 2 cannot be found"
