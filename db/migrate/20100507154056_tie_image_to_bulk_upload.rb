class TieImageToBulkUpload < ActiveRecord::Migration
  def self.up
    add_column :images, :bulk_upload_id, :integer
  end

  def self.down
    remove_column :images, :bulk_upload_id
  end
end
