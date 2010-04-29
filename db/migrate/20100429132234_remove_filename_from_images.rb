class RemoveFilenameFromImages < ActiveRecord::Migration
  def self.up
    remove_column :images, :filename
  end

  def self.down
    add_column :images, :filename, :string
  end
end
