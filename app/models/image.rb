class Image < ActiveRecord::Base
  named_scope :for_batch, proc { |batch|
    { :conditions => [ 'batch_id=?', batch.id ] }
  }
  
  named_scope :by_batch_and_image_id, proc { |batch,image_id|
    { :conditions => [ 'batch_id=? AND id=?', batch.id, image_id ] }
  }
end
