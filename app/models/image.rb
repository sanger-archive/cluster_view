# Clusterview is about viewing images, each Image instance represents a photograph of the
# clusters on a slide.  Each Batch instance has 16 images, 2 per lane, and they are generally
# greyscale TIFF images.
class Image < ActiveRecord::Base
  
  has_attached_file :data,
    :storage => :database, :column => "data_file",
    :styles => { :thumbnail => {:geometry => "400x400>", :format => "jpg", :column => "data_thumbnail_file"} },
    :convert_options => { :thumbnail => "-normalize" }
    
    # Not sure if this validation will be a pain but don't think we'll create an image
    # without an attachment, so...
    # validates_attachment_presence :data
    

  validates_presence_of :position
  validates_numericality_of :position, :integer_only => true
  validates_inclusion_of :position, :in => (0..15)

  named_scope :for_batch, proc { |batch|
    { :conditions => [ 'batch_id=?', batch.id ], :order => 'position' }
  }
  
  named_scope :by_batch_and_image_id, proc { |batch,image_id|
    { :conditions => [ 'batch_id=? AND id=?', batch.id, image_id ], :order => 'position' }
  }
  
  def root_filename
    File.basename(data_file_name, ".*")
  end
  
  def filename
    self.data_file_name
  end
  
  def data_thumbnail_file_name
    "#{self.root_filename}.jpg"
  end
end
