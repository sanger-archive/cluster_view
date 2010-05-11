@requires_user_to_be_logged_in
Feature: The ability to compare two lanes across two batches.
  Sometimes lanes on a batch can fail and the lab people then rerun that lane in another batch to
  see if they can determine what might have gone wrong.  They need the ability to compare those
  two lanes, like a "before" and "after", side-by-side to see any differences.

  Background:
    Given the samples for batches are:
      | sample  |batch|lane|
      |Sample #1| 456 | 1  |
      |Sample #2| 456 | 2  |
      |Sample #3| 789 | 3  |
      |Sample #1| 789 | 6  |
    And batch ID "2" is invalid
    Then setup the batches

  Scenario: Comparing two lanes side-by-side
    Given I am on the homepage
    When I choose to compare lane "1" of batch "456" with lane "6" of batch "789"
    Then I should be on the batch comparison page
    And I should see "Batch 456, Lane 1, Sample: Sample #1"
    And I should see "Batch 789, Lane 6, Sample: Sample #1"

  Scenario: One of the batches does not exist
    Given I am on the homepage
    When I choose to compare lane "1" of batch "456" with lane "2" of batch "2"
    Then I should be on the homepage
    And I should see "Batch 2 cannot be found"

  Scenario: Comparing the same lane against itself
    Given I am on the homepage
    When I choose to compare lane "1" of batch "456" with lane "1" of batch "456"
    Then I should be on the homepage
    And I should see "Comparing the same lane against itself makes no sense!"

  Scenario: The two lanes do not appear to come from the same sample
    Given I am on the homepage
    When I choose to compare lane "1" of batch "456" with lane "3" of batch "789"
    Then I should be on the batch comparison page
    And I should see "Batch 456, Lane 1, Sample: Sample #1"
    And I should see "Batch 789, Lane 3, Sample: Sample #3"
    And I should see "The lanes appear to not be from the same sample"

  @wip
  Scenario: Comparing a batch from a batch page
