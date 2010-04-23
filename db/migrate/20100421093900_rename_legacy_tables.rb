# This is the first step in the migration of the legacy database, which may not exist in the
# current Rails environment.  If it does we simply rename the tables at this point so that
# we get no clashes.
class RenameLegacyTables < ActiveRecord::Migration
  LEGACY_TABLES = [ 'users', 'sessions', 'images' ]

  LEGACY_INDICES = {
    'sessions' => [ 'session_id', 'updated_at' ]
  }

  def self.up
    LEGACY_INDICES.each { |table,indices| handle_legacy_index(:up, table, indices) }
    LEGACY_TABLES.each { |table| rename_legacy_table(:up, table) }
  end

  def self.down
    LEGACY_TABLES.each { |table| rename_legacy_table(:down, table) }
    LEGACY_INDICES.each { |table,indices| handle_legacy_index(:down, table, indices) }
  end

  def self.rename_legacy_table(direction, table)
    args = [ table, "legacy_#{ table }" ]
    args.reverse! if direction == :down
    rename_table(*args) if table_exists?(args.first)
  end

  def self.handle_legacy_index(direction, table, indices)
    return unless table_exists?(table)
    operation = (direction == :up) ? :remove_index : :add_index
    indices.each { |index| send(operation, table, index) }
  end
end
