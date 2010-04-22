Feature: Access to the system is authenticated

  Scenario: No users in the system
    Given there are no registered users
    And I am not logged in
    When I attempt to login as "John Smith"
    Then I should not be logged in
    And I should see an authentication error

  Scenario: Invalid login
    Given the user "John Smith" is registered
    And I am not logged in
    When I attempt to login as "Fred Perry"
    Then I should not be logged in
    And I should see an authentication error

  Scenario: Valid login but incorrect password
    Given the user "John Smith" is registered
    And I am not logged in
    When I attempt to login as "John Smith" with password "foobar"
    Then I should not be logged in
    And I should see an authentication error

  Scenario: Valid login and password
    Given the user "John Smith" is registered
    And I am not logged in
    When I attempt to login as "John Smith"
    Then I should be logged in as "John Smith"
