# Module providing the functionality for migrating the legacy data.  Enables us to repeat
# the migrations if something goes wrong, without having to worry about how it functions!
module Legacy
  LEGACY_TABLE_TO_MIGRATE = 'legacy_images'

  class Image < ActiveRecord::Base
    self.table_name = Legacy::LEGACY_TABLE_TO_MIGRATE

    named_scope :valid_position, :conditions => [ 'position BETWEEN 1 AND 16' ]
    named_scope :valid_filename, :conditions => [ 'filename IS NOT NULL' ]
    named_scope :not_already_migrated, :conditions => [ '(migrated IS NULL OR migrated=0)' ]

    def self.valid_for_migration
      [ :not_already_migrated, :valid_position, :valid_filename ].inject(self) { |target,scope| target.send(scope) }
    end

    { :migrated! => true, :not_migrated! => false }.each do |method,state|
      define_method(method) do
        self.update_attribute(:migrated, state) if self.class.column_names.include?('migrated')
      end
    end
  end

  module ImageMigration
    def self.extended(base)
      # If the legacy table doesn't exist then we don't actually need to do any work, so the
      # simple thing to do is say there is nothing to migrate!
      Legacy::Image.class_eval do
        define_method(:all) { [] }
      end unless base.table_exists?(Legacy::LEGACY_TABLE_TO_MIGRATE)
    end

    # This constants maps the legacy positions to the new sequence.  The array values are the
    # legacy positions, their index within the array is the new position.  So simple reverse
    # lookup, i.e. LEGACY_POSITIONS_TO_NEW_VALUES.index(legacy_position) = new_position
    #
    # It looks like the photographs are taken lane 8-1 then lane 1-8.
    LEGACY_POSITIONS_TO_NEW_VALUES = [
      8,  9,
      7, 10,
      6, 11,
      5, 12,
      4, 13,
      3, 14,
      2, 15,
      1, 16
    ]

    def migrate_legacy_images(images = Legacy::Image.valid_for_migration)
      expected, limit = images.count, (ENV['batch_size'] || 50).to_i

      say(RAILS_DEFAULT_LOGGER.info("About to migrate #{ expected } in batches of #{ limit } ..."))

      # Find all of the legacy images and migrate them in batches to reduce the memory consumption
      # and transaction time.  Can't use find_in_batches because it'll order only by one column and
      # created_at is not unique.
      migrated = total = 0
      migrating = images.all(:order => 'created_at DESC, id DESC')
      while !migrating.empty?
        ActiveRecord::Base.transaction do
          (0...limit).each do |_|
            break if migrating.empty?

            image        = migrating.shift
            new_position = LEGACY_POSITIONS_TO_NEW_VALUES.index(image.position.to_i) or raise StandardError, "Legacy position #{ image.position } unmapped!"
            filename     = File.expand_path(File.join(Settings.legacy_clusterview_image_path, image.filename))

            begin
              begin
                File.open(filename, 'r') { |file| ::Image.create!(:batch_id => image.batch_id.to_i, :position => new_position, :data => file) }
                migrated += 1
              ensure
                total    += 1
                image.migrated!
              end
            rescue ActiveRecord::RecordInvalid => exception
              say(RAILS_DEFAULT_LOGGER.info("Legacy image file #{ filename } has errors - #{ exception.message }"))
            rescue Errno::ENOENT => exception
              say(RAILS_DEFAULT_LOGGER.info("Legacy image file #{ filename } is missing - source image #{ image.id }"))
            end
          end
        end
        
        say(RAILS_DEFAULT_LOGGER.info("Migrated #{ migrated } legacy images out of #{ total }(#{ expected }) so far"))
      end
    end
  end
end
