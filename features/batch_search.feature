Feature: Batch search
  In order to find a particular batch
  As a user
  I want to pass a batch number
	And be presented with the corresponding batch

	Scenario: Search a valid batch ID
	  Given I am on the batch search page
	  When I search for a valid batch ID of "1044" 
	  Then I should see "Batch ID: 1044"
	
	Scenario: Search for batch that doesn't exit
	  Given I am on the batch search page
	  When I search for an invalid batch ID of "2"
	  Then I should see "Batch 2 cannot be found"
