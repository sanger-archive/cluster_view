class UpdateImageLocationsToBottomRight < ActiveRecord::Migration
  
  def self.swap_image_positions
    # Move Images at positions 0, 2, 4, 6, 8, 10, 12 and 14 from the left to a holding position.
    left_to_holding_map = [ [14,35],[12,33],[10,31],[8,29],[6,27],[4,25],[2,23],[0,21] ]
    self.move_images(left_to_holding_map)
    
    # Move Image at positions 15, 13, 11, 9, 7, 5, 3 and 1 to the left
    right_to_left_map = [ [15,14],[13,12],[11,10],[9,8],[7,6],[5,4],[3,2],[1,0] ]
    self.move_images(right_to_left_map)
    
    # Move Images from 35, 33, 31, 29, 27, 25, 23 and 21 to the now vacent positions on the right
    holding_to_right_map = [ [35,15],[33,13],[31,11],[29,9],[27,7],[25,5],[23,3],[21,1] ]
    self.move_images(holding_to_right_map)
  end
  
  # Takes an array of positions in the form of:-
  # [[original_position, destination_position],[original_position, destination_position],...]
  def self.move_images(position_map)
    position_map.each do |image_positions|
      original_position, destination_position = *image_positions
      
      Image.connection.execute("UPDATE images SET position = #{destination_position} where position = #{original_position}")
    end
  end
  
  
  def self.up
    self.swap_image_positions()
  end                                                        

  def self.down                                              
    self.swap_image_positions()
  end
end
