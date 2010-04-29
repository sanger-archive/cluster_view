require 'ostruct'

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
  
  # Mainly used to update the images associated with an instance of this class.  It should handle
  # the form data posted through BatchController#update action and yield each of the images that
  # have been updated to the specified block (if given).
  def update_attributes(attributes, &block)
    attributes.fetch(:images, []).each do |position,image_attributes|
      update_attributes_event = event_type_from_parameters(image_attributes) or next
      image = send(:"update_attributes_by_#{ update_attributes_event }", image_attributes.merge(:position => position))
      yield(update_attributes_event, image) if block_given?
    end
  end

  def samples
    self.lanes.lane.map do |lane|
      sample_type = lane.respond_to?(:library) ? :library : :control
      OpenStruct.new(:lane => lane.position.to_i, :name => lane.send(sample_type).name)
    end
  end

  # Yields the sample and images (left and right) for this instance.  Images can be nil and the sample
  # is an object that responds to :lane and :name (see Batch#samples).
  def lane_organised_images(&block)
    images = self.images.inject([ nil ] * 16) { |images,image| images[ image.position ] = image ; images }
    self.samples.zip(images.in_groups_of(2)).each do |sample,(left,right)|
      yield(sample, left, right)
    end
  end

private

  def update_attributes_by_update(image_attributes)
    image = Image.by_batch_and_image_id(self, image_attributes[ :id ]).first
    image.update_attributes(image_attributes)
    image
  end

  def update_attributes_by_create(image_attributes)
    Image.create!(image_attributes.update(:batch_id => self.id))
  end

  def update_attributes_by_delete(image_attributes)
    image = Image.by_batch_and_image_id(self, image_attributes[ :id ]).first
    image.destroy
    image
  end

  def event_type_from_parameters(parameters)
    case
    when parameters.key?(:delete)   then :delete
    when parameters[ :data ].blank? then nil
    when !parameters.key?(:id)      then :create
    else :update
    end
  end
end
