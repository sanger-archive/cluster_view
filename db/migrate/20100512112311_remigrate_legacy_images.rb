require 'legacy_data_migration'

# This is here because the initial migration of the legacy data seems to have become very confused
# and migrated more than 16 images per batch and not generated thumbnails.  I hope that's because it
# was stopped-and-skipped or something.
class RemigrateLegacyImages < ActiveRecord::Migration
  extend Legacy::ImageMigration

  def self.up
    # If the number of images we have migrated is less thant that in the legacy image system
    # then we need to retry because something went serious wrong before!
    unless Image.count >= Legacy::Image.valid_for_migration.count
      Image.transaction do
        Image.destroy_all
        self.migrate_legacy_images
      end
    end if table_exists?(Legacy::LEGACY_TABLE_TO_MIGRATE)
  end

  def self.down
    # Actually we have nothing we need to do here!
  end
end
