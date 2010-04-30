# Clusterview is about viewing images, each Image instance represents a photograph of the
# clusters on a slide.  Each Batch instance has 16 images, 2 per lane, and they are generally
# greyscale TIFF images.
class Image < ActiveRecord::Base
  
  DATA_THUMBNAIL_CONTENT_TYPE = "image/jpeg"
  
  has_attached_file :data,
    :storage => :database, :column => "data_file",
    :styles => { :thumbnail => {:geometry => "400x400>", :format => "jpg", :column => "data_thumbnail_file"} },
    :convert_options => { :thumbnail => "-normalize" }

  # We do not need to destroy the attachments as they are part of the database, so override
  # this method to do nothing!
  def destroy_attached_files
    # Nothing to do
  end

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
    File.basename(self.data_file_name, ".*")
  end
  
  def data_thumbnail_file_name
    "#{self.root_filename}.jpg"
  end
  
  def data_thumbnail_content_type
    DATA_THUMBNAIL_CONTENT_TYPE
  end

  # Column aliases to support the self.define_send_image_data_via(image_type)
  alias_attribute :data_image_file, :data_file
  alias_attribute :data_image_content_type, :data_content_type
  alias_attribute :data_image_file_name, :data_file_name
  
  # Creates a method to send a type of image back to conduit class (e.g. a Controller)
  # with the correct MIME type and filename.
  def self.define_send_image_data_via(image_type)
    define_method(:"send_#{image_type}_data_via") do |conduit, options|
      conduit.send_data(
        self.send(:"data_#{image_type}_file"),
        options.merge(
          :type => self.send(:"data_#{image_type}_content_type"), 
          :filename => self.send(:"data_#{image_type}_file_name")
        )
      )
    end
  end
  
  define_send_image_data_via(:thumbnail)
  define_send_image_data_via(:image)
  
end
