class DropBulkUploadIdFromImages < ActiveRecord::Migration
  def self.up
    remove_column :images, :bulk_upload_id
  end

  def self.down
    add_column :images, :bulk_upload_id, :integer
  end
end
