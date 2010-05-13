require 'paperclip/fixes_for_db'

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

  # The position of the image must be unique within the Batch instance, or within the BulkUpload instance.
  validates_uniqueness_of :position, :scope => :batch_id, :if => :batch_id?
  validates_uniqueness_of :position, :scope => :bulk_upload_id, :if => :bulk_upload_id?

  named_scope :for_batch, proc { |batch|
    { :conditions => [ 'batch_id=?', batch.id ], :order => 'position' }
  }
  
  named_scope :by_batch_and_image_id, proc { |batch,image_id|
    { :conditions => [ 'batch_id=? AND id=?', batch.id, image_id ], :order => 'position' }
  }

  named_scope :for_bulk_upload, proc { |bulk_upload|
    { :conditions => [ 'bulk_upload_id=?', bulk_upload.id ], :order => 'position' }
  }

  named_scope :in_position, proc { |position|
    { :conditions => [ 'position=?', position ] }
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
    define_method(:"send_#{image_type}_data_via") do |*args|
      conduit, options = args
      options ||= {}

      component_data = self.send(:"data_#{ image_type }_file")
      if component_data.nil?
        conduit.error_as_no_data_for(self)
        return
      end

      conduit.send_data(
        component_data,
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
