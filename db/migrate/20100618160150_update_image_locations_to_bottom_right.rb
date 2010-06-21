class UpdateImageLocationsToBottomRight < ActiveRecord::Migration
  
  def self.swap_image_positions
    Image.connection.execute("UPDATE images SET position = position - (2 * (position % 2)) + 1")
  end  
  
  def self.up
    self.swap_image_positions()
  end                                                        

  def self.down                                              
    self.swap_image_positions()
  end
end
