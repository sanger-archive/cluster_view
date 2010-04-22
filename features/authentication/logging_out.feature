Feature: Authenticated users can log out

  Scenario: Logging out when logged in
    Given the user "John Smith" is registered
    And I am logged in as "John Smith"
    When I logout
    Then I should not be logged in

  Scenario: Logging out when already logged out
    Given the user "John Smith" is registered
    And I am not logged in
    When I logout
    Then I should not be logged in
