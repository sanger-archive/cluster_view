class CreateBulkUploadImages < ActiveRecord::Migration
  def self.up
    create_table :bulk_upload_images do |t|
      t.integer :batch_id
      t.integer :bulk_upload_id
      t.integer :position

      t.binary :data_file, :limit => 10.megabytes
      t.binary :data_thumbnail_file, :limit => 10.megabytes
      t.string :data_file_name
      t.integer :data_file_size
      t.datetime :data_updated_at
      t.string :data_content_type

      t.timestamps
    end
  end

  def self.down
    drop_table :bulk_upload_images
  end
end
