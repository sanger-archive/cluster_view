class AddMigratedToLegacyImages < ActiveRecord::Migration
  def self.up
    add_column(Legacy::LEGACY_TABLE_TO_MIGRATE, :migrated, :boolean, :default => false) if table_exists?(Legacy::LEGACY_TABLE_TO_MIGRATE)
  end

  def self.down
    remove_column(Legacy::LEGACY_TABLE_TO_MIGRATE, :migrated) if table_exists?(Legacy::LEGACY_TABLE_TO_MIGRATE)
  end
end
