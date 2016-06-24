# When uploading multiple images in one step an instance of this model is created for the duration
# of the upload.  This enables us to do some better error handling and dealing with the necessary
# updates to the Batch.
class BulkUpload < ActiveRecord::Base
  module ImagesExtension
    # Returns the Image instances so that they are sorted by the numerical value of their filename,
    # rather than the alphabetic.  This ensures that the sequence is correct for positional
    # adjustment later.
    def sorted_numerically
      self.all.sort do |left,right|
        numeric_from_filename(left.data_file_name) <=> numeric_from_filename(right.data_file_name)
      end
    end

    def numeric_from_filename(filename)
      match = /^[a-zA-Z]*(\d+)\..+$/.match(filename) or raise "Filename '#{ filename }' does not appear to be numeric"
      match[ 1 ].to_i
    end
  end

  has_many :images, :extend => ImagesExtension, :class_name => 'BulkUploadImage', :dependent => :destroy

  before_create :clean_up_leftovers!

  # Each upload of an image is attached to this instance through this method.  At this point the image
  # position is simply assumed to be based on the number that have been previously uploaded.
  def upload_data(source, index = nil)
    index ||= self.images.length

    # Because the BulkUpload could be resuming from a previously failed state we need to destroy all of
    # the Image instances that may occupy our position.
    self.images.in_position(index).each {|i| i.destroy}
    self.images.create!(:data => source[:file], :position => index)
  end

  # Attaches all of the images that have been uploaded within this bulk upload to the specified Batch
  # instance, and then destroys this instance.
  def complete_for_batch!(batch_id)
    batch = complete_for_batch(Batch.find(batch_id))
    self.destroy
    batch
  end

  # Destroying upload attempts older than X hours (-which are most likely stale!) should keep this
  # staging-table from growing beyond reasonable size.
  # (could've used a scope, but try search the web for "rails 2.3 bugs named_scope destroy_all")
  def clean_up_leftovers!
    nr_deleted = BulkUpload.destroy_all(["created_at < ?", 4.hours.ago]).count
    Rails.logger.info("BulkUpload cleared out #{nr_deleted} record(s)") unless nr_deleted.zero?
  end

private

  # The index of an Image instance within the +images+ association, when sorted numerically, can be
  # mapped to the physical position of the image on the batch.  Essentially the images are take from
  # lane 8 up to lane 1 and then back down from lane 1 to lane 8.
  POSITION_FROM_INDEX = [15, 13, 11, 9, 7, 5, 3, 1, 0, 2, 4, 6, 8, 10, 12, 14]


  # Does the heavy lifting associated with completing a bulk upload for the given Batch.
  # Destroys all of the images currently associated with the given batch and then associates all
  # of the images associated with this instance to that Batch.  The images are associated such
  # that they are in the correct order for the view.
  def complete_for_batch(batch)
    BulkUploadImage.transaction do
      # First thing we do is remap the position of the images attached to us so that they will be
      # correct when attached to a Batch.
      self.images.sorted_numerically.each_with_index do |image,index|
        image.batch_id = batch.id
        image.position = POSITION_FROM_INDEX[ index ]
        image.save(false)
      end

      # Now we know that those images have passed the necessary validations for attachment to Batch
      # and are correctly positioned, we can simply bulk insert them into the images table.  This is
      # an efficiency saving as validates_uniqueness_of, used for the position checks, is horribly,
      # horribly slow on such a large table.
      Image.transaction do
        Image.for_batch(batch).all.each(&:destroy)
        Image.insert_from_bulk_upload(self)
      end

      batch
    end
  end
end
