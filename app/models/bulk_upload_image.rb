class BulkUploadImage < ActiveRecord::Base
  include ImageBehaviour

  validates_uniqueness_of :position, :scope => :bulk_upload_id

  named_scope :for_bulk_upload, lambda { |bulk_upload|
    { :conditions => [ 'bulk_upload_id=?', bulk_upload.id ] }
  }
end
