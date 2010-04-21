Feature: Batch search
  In order to find a particular batch
  As a user
  I want to pass a batch number
	And be presented with the corresponding batch

	Scenario: Search a valid batch number
		Given I am on the batch search page
	  When I search for batch number "1044" 
	  Then I see the batch page for batch "1044"
	
	Scenario: Search for an unknown batch number
		Given I am on the batch search page
		When I search for a non-existent batch number "2"
	  Then I should see "Batch not found"
	
	
	
	
	
