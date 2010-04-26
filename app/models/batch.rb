# An instance of this class represents a slide that is being put through the sequencing process.
# Each Batch has a 8 lanes in which there are a number of samples.
class Batch < ActiveResource::Base
  self.site = Settings.sequencescape_url

  class << self
    def human_name
      self.name.humanize
    end
  end
  
  def images
    Image.for_batch(self)
  end
  
  def update_attributes(attributes)
    attributes.fetch(:images, []).each do |image_attributes|
      if image_attributes.key?(:id)
        image = Image.by_batch_and_image_id(self, image_attributes[ :id ])
        image.update_attributes(image_attributes)
      else
        Image.create!(image_attributes.update(:batch_id => self.id))
      end
    end
  end
end
