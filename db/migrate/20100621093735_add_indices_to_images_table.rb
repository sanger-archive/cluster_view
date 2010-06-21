class AddIndicesToImagesTable < ActiveRecord::Migration
  def self.up
    add_index :images, [ :batch_id, :position ], :unique => true, :name => 'position_within_batch_is_unique'
  end

  def self.down
    remove_index :images, :name => 'position_within_batch_is_unique'
  end
end
