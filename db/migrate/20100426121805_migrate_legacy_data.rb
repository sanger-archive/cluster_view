# At the point at which this migration is executed we have two databases co-existing.  We
# migrate the data we need from the legacy tables at this point.
class MigrateLegacyData < ActiveRecord::Migration
  LEGACY_TABLE_TO_MIGRATE = 'legacy_images'

  module Legacy
    class Image < ActiveRecord::Base
      self.table_name = LEGACY_TABLE_TO_MIGRATE
    end
  end

  # If the legacy table doesn't exist then we don't actually need to do any work, so the
  # simple thing to do is say there is nothing to migrate!
  class Legacy::Image
    def self.all
      []
    end
  end unless table_exists?(LEGACY_TABLE_TO_MIGRATE)

  def self.up
    Legacy::Image.all.each do |image|
      Image.create!(:batch_id => image.batch_id.to_i, :filename => image.filename)
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, 'Unable to reverse the legacy data migration'
  end
end
