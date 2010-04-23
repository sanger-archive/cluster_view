Feature: Image Upload
  In order to associate images with a batch
  As a User
  I want to individually upload images to a batch

  Scenario: I upload an image to a fresh batch object
    Given batch ID "1044" is valid
    And I am on the show page for batch "1044"
    When I attach the file "features/images/2617.tif" to "Image"
    And I press "Upload"
    Then I should be on the show page for batch "1044"
    And I should see "Image 2617.tif uploaded successfully"
    And I should see a thumbnail for "2617"
  
  
  
