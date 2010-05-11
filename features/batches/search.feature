@requires_user_to_be_logged_in
Feature: Batch search
  In order to find a particular batch
  As a user
  I want to pass a batch number
	And be presented with the corresponding batch

  Background:
    Given I am on the batch search page
    And the batches are:
      | id | state |
      |1044| valid |
      | 2  |invalid|
    Then setup the batches

	Scenario: Search a valid batch ID
	  When I search for batch ID "1044" 
	  Then I should see "Batch ID: 1044"
	
	Scenario: Search for batch that doesn't exist
	  When I search for batch ID "2"
	  Then I should see "Batch 2 cannot be found"

  Scenario: Search for one batch that does not exist, then for one that does, should not display batch not found!
    When I search for batch ID "2"
    Then I should see "Batch 2 cannot be found"

    When I search for batch ID "1044"
    Then I should not see "Batch 2 cannot be found"
