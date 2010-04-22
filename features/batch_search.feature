Feature: Batch search
  In order to find a particular batch
  As a user
  I want to pass a batch number
	And be presented with the corresponding batch

	Scenario: Search a valid batch number
	  Given I am on the batches page
	  When I search for a batch number of "1044" 
	  Then I should see "Batch Number: 1044"
	
	Scenario: Search for batch that doesn't exit
	  Given I am on the batches page
		And there is no batch with a number of "2"
	  When I search for a batch number of "2"
	  Then I should see "Batch 2 cannot be found"