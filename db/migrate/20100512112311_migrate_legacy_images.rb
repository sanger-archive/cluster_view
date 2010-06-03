require 'legacy_data_migration'

# At the point at which this migration is executed we have two databases co-existing.  We
# migrate the data we need from the legacy tables at this point.
class MigrateLegacyImages < ActiveRecord::Migration
  extend Legacy::ImageMigration

  def self.up
    self.migrate_legacy_images if table_exists?(Legacy::LEGACY_TABLE_TO_MIGRATE)
  end

  def self.down
    # Actually we don't need to really do anything here because this hasn't touched the
    # legacy tables.  Yes, data may be lost from the current tables when switching back to
    # the legacy, but we should arrive in no different a situation that before the migrations
    # were run.
  end
end
