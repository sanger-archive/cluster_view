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

  # Each upload of an image is attached to this instance through this method.  At this point the image
  # position is simply assumed to be based on the number that have been previously uploaded.
  def upload_data(source, index = nil)
    index ||= self.images.length

    # Because the BulkUpload could be resuming from a previously failed state we need to destroy all of
    # the Image instances that may occupy our position.
    self.images.in_position(index).destroy_all
    self.images.create!(:data => source, :position => index)
  end

  # Attaches all of the images that have been uploaded within this bulk upload to the specified Batch
  # instance, and then destroys this instance.
  def complete_for_batch!(batch_id)
    batch = complete_for_batch(Batch.find(batch_id))
    self.destroy
    batch
  end

private

  # The index of an Image instance within the +images+ association, when sorted numerically, can be
  # mapped to the physical position of the image on the batch.  Essentially the images are take from
  # lane 8 up to lane 1 and then back down from lane 1 to lane 8.
  POSITION_FROM_INDEX = [ 14, 12, 10, 8, 6, 4, 2, 0, 1, 3, 5, 7, 9, 11, 13, 15 ]

  # Does the heavy lifting associated with completing a bulk upload for the given Batch.
  # Destroys all of the images currently associated with the given batch and then associates all
  # of the images associated with this instance to that Batch.  The images are associated such
  # that they are in the correct order for the view.
  def complete_for_batch(batch)
    BulkUploadImage.transaction do
      # We can prebuild the image data ...
      image_data = []
      self.images.sorted_numerically.each_with_index do |image,index|
        image_data.push(:batch_id => batch.id, :position => POSITION_FROM_INDEX[ index ], :data => image.data)
      end

      # ... then do the necessary image changes
      Image.transaction do
        Image.all(:conditions => { :batch_id => batch.id }).each(&:destroy)
        Image.create!(image_data)
      end
      
      batch
    end
  end
end
