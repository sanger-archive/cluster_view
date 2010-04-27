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
      next if [ :filename, :data ].any? { |field| image_attributes[ field ].blank? }

      image_attributes.update(:position => position)
      image_attributes[ :filename ] = File.basename(image_attributes[ :filename ])
      image_attributes[ :data ] = image_attributes[ :data ].read # TODO[md12]: remove with paperclip

      event_type, image = if image_attributes.key?(:id)
        image = Image.by_batch_and_image_id(self, image_attributes[ :id ])
        image.update_attributes(image_attributes)
        [ :updated, image ]
      else
        [ :created, Image.create!(image_attributes.update(:batch_id => self.id)) ]
      end

      yield(event_type, image) if block_given?
    end
  end

  def samples
    self.lanes.lane.map do |lane|
      sample_type = lane.respond_to?(:library) ? :library : :control
      Sample.new(lane.position.to_i, lane.send(sample_type).name)
    end
  end

private

  class Sample
    attr_reader :lane, :name

    def initialize(lane, name)
      @lane, @name = lane, name
    end
  end
end
