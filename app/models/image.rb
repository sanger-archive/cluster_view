# Clusterview is about viewing images, each Image instance represents a photograph of the
# clusters on a slide.  Each Batch instance has 16 images, 2 per lane, and they are generally
# greyscale TIFF images.
class Image < ActiveRecord::Base
  include ImageBehaviour
  
  DATA_THUMBNAIL_CONTENT_TYPE = "image/jpeg"

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

  COLUMNS_FOR_BULK_INSERT = %w{batch_id position created_at updated_at data_file data_thumbnail_file data_file_name data_file_size data_content_type data_updated_at}.join(',')

  def self.insert_from_bulk_upload(bulk_upload)
    self.connection.execute(%Q{
      INSERT INTO images(#{ COLUMNS_FOR_BULK_INSERT }) SELECT #{ COLUMNS_FOR_BULK_INSERT } FROM bulk_upload_images WHERE bulk_upload_id = #{ bulk_upload.id }
    })
  end
  
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
