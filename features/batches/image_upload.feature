Feature: Image Upload
  In order to associate images with a batch
  As a User
  I want to individually upload images to a batch
  
  Scenario: Uploading an image in an empty position
    Given batch ID "1023" is valid
    And batch "1023" has no images
    And I am on the show page for batch "1023"
    When I attach the file "features/images/2617.tif" for the left image in lane 1
    And I press "Upload"
    Then I should be on the show page for batch "1023"
    And I should see "Image 2617.tif created successfully"
    And I should not see "Image empty created successfully"
    And I should see the left thumbnail in lane "1" as "2617.tif"
