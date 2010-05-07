# When uploading multiple images in one step an instance of this model is created for the duration 
# of the upload.  This enables us to do some better error handling and dealing with the necessary
# updates to the Batch.
class BulkUpload < ActiveRecord::Base
  has_many :images, :order => 'data_file_name ASC'

  # Each upload of an image is attached to this instance through this method.  At this point the image
  # position is simply assumed to be based on the number that have been previously uploaded.
  def upload_data(source)
    Image.create!(:bulk_upload_id => self.id, :data => source, :position => self.images.length)
  end

  # Attaches all of the images that have been uploaded within this bulk upload to the specified Batch
  # instance, and then destroys this instance.
  def complete_for_batch!(batch_id)
    batch = complete_for_batch(Batch.find(batch_id))
    self.destroy
    batch
  end

private

  # Does the heavy lifting associated with completing a bulk upload for the given Batch.
  # Destroys all of the images currently associated with the given batch and then associates all
  # of the images associated with this instance to that Batch.  The images are associated such
  # that they are in the correct order for the view.
  def complete_for_batch(batch)
    Image.transaction do
      batch.images.each { |image| image.destroy }
      self.images.each_with_index do |image,index|
        image.update_attributes(:batch_id => batch.id, :bulk_upload_id => nil, :position => index)
      end
      batch
    end
  end
end
