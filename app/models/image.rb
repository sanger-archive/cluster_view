# Clusterview is about viewing images, each Image instance represents a photograph of the
# clusters on a slide.  Each Batch instance has 16 images, 2 per lane, and they are generally
# greyscale TIFF images.
class Image < ActiveRecord::Base
  named_scope :for_batch, proc { |batch|
    { :conditions => [ 'batch_id=?', batch.id ] }
  }
  
  named_scope :by_batch_and_image_id, proc { |batch,image_id|
    { :conditions => [ 'batch_id=? AND id=?', batch.id, image_id ] }
  }
end
