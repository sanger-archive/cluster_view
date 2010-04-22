Feature: Authenticated returning users are not challenged

  Scenario: Authenticated user who returns before session expiry
    Given the user "John Smith" is registered
    And I logged in as "John Smith" 1 week ago
    When I visit a secure area of the application
    Then I should not be challenged to log in

  Scenario: Authenticated user who returns after session expiry
    Given the user "John Smith" is registered
    And I logged in as "John Smith" 3 weeks ago
    When I visit a secure area of the application
    Then I should be challenged to log in
