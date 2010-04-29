class AddAttachmentToImage < ActiveRecord::Migration
  def self.up
    # :limit => 10.megabytes used to force MySQL to use MEDIUMBLOB
    # otherwise image sizes will max out at 64kB (Blob).
    add_column :images, :data_file, :binary, :limit => 10.megabytes
    add_column :images, :data_thumbnail_file, :binary, :limit => 10.megabytes
    add_column :images, :data_file_name, :string
    add_column :images, :data_file_size, :integer
    add_column :images, :data_updated_at, :datetime
    add_column :images, :data_content_type, :string
  end

  def self.down
    remove_column :images, :data_content_type
    remove_column :images, :data_updated_at
    remove_column :images, :data_file_size
    remove_column :images, :data_file_name
    remove_column :images, :data_file
    remove_column :images, :data_thumbnail_file
  end
end
