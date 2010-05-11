@requires_user_to_be_logged_in
Feature: Technicians need to be able to delete images from a batch
  Background:
    Given batch ID "3456" is valid
    Then setup the batches

  Scenario: Deleting an image
    And batch "3456" has image "features/images/2617.tif" for the left image in lane 3
    And I am on the show page for batch "3456"
    Then the "Delete image 2617" checkbox should not be checked

    When I check "Delete image 2617"
    And I press "Upload"
    Then I should be on the show page for batch "3456"
    And I should see "Image 2617.tif deleted successfully"
    And I should not see a left thumbnail in lane 3
    And I should not see an option "Delete image 2617"

  Scenario: Deleting multiple images
    And batch "3456" has image "features/images/2617.tif" for the left image in lane 3
    And batch "3456" has image "features/images/2618.tif" for the right image in lane 5
    And I am on the show page for batch "3456"
    Then the "Delete image 2617" checkbox should not be checked
    And the "Delete image 2618" checkbox should not be checked

    When I check "Delete image 2617"
    And I check "Delete image 2618"
    And I press "Upload"
    Then I should be on the show page for batch "3456"
    And I should see "Image 2617.tif deleted successfully"
    And I should see "Image 2618.tif deleted successfully"
    And I should not see a left thumbnail in lane 3
    And I should not see an option "Delete image 2617"
    And I should not see a right thumbnail in lane 5
    And I should not see an option "Delete image 2618"

  Scenario: Deleting one of multiple images
    And batch "3456" has image "features/images/2617.tif" for the left image in lane 3
    And batch "3456" has image "features/images/2618.tif" for the right image in lane 5
    And I am on the show page for batch "3456"
    Then the "Delete image 2617" checkbox should not be checked
    And the "Delete image 2618" checkbox should not be checked

    When I check "Delete image 2617"
    And I press "Upload"
    Then I should be on the show page for batch "3456"
    And I should see "Image 2617.tif deleted successfully"
    And I should not see a left thumbnail in lane 3
    And I should not see an option "Delete image 2617"
