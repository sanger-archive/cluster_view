# Slightly alter the behaviour of the MySQL adapter so that the :binary column type gets mapped to
# a useful blob size in the actual database.
class ActiveRecord::ConnectionAdapters::MysqlAdapter
  def self.native_database_types
    NATIVE_DATABASE_TYPES.merge(:binary => { :name => 'mediumblob' })
  end
end

class AddDataToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :data, :binary 
  end

  def self.down
    remove_column :images, :data
  end
end
