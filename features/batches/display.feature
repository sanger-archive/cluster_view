Feature: Batch display
  Scenario: Batch with no images
    Given batch ID "2010" is valid
    And batch "2010" has no images
    When I view batch "2010"
    Then I should see no batch thumbnails

  Scenario: Batch with 16 images
    Given batch ID "2011" is valid
    And batch "2011" has images 1 to 16
    When I view batch "2011"
    Then I should see lanes with thumbnails:
      |lane|left|right|
      |1   |001 |  002|
      |2   |003 |  004|
      |3   |005 |  006|
      |4   |007 |  008|
      |5   |009 |  010|
      |6   |011 |  012|
      |7   |013 |  014|
      |8   |015 |  016|

