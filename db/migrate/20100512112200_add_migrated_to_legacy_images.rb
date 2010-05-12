class AddMigratedToLegacyImages < ActiveRecord::Migration
  def self.up
    add_column(:legacy_images, :migrated, :boolean, :default => false) if table_exists?(:legacy_images)
  end

  def self.down
    remove_column(:legacy_images, :migrated) if table_exists?(:legacy_images)
  end
end
