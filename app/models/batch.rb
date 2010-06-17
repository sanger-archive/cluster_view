require 'ostruct'

# An instance of this class represents a slide that is being put through the sequencing process.
# Each Batch has a 8 lanes in which there are a number of samples.
class Batch < ActiveResource::Base
  class BatchNotFound < StandardError
    attr_reader :batch_id

    def initialize(batch_id)
      @batch_id = batch_id
    end
  end

  self.site    = Settings.sequencescape_url
  self.timeout = Settings.timeout_to_sequencescape
  self.headers.update('User-Agent' => Settings.user_agent_for_sequencescape)

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
    attributes.fetch(:images, []).each_with_index do |image_attributes,position|
      next if image_attributes.blank?

      update_attributes_event = self.class.event_type_from_parameters(image_attributes) or next
      image_attributes.delete(:delete)
      image = send(:"update_attributes_by_#{ update_attributes_event }", image_attributes.merge(:position => position))
      yield(update_attributes_event, image) if block_given?
    end
  end

  def samples
    self.lanes.lane.map do |lane|
      sample_type = lane.respond_to?(:library) ? :library : :control
      Sample.new(self, lane.position.to_i, lane.send(sample_type).name)
    end
  end

private

  def update_attributes_by_update(image_attributes)
    image = image_for_id!(image_attributes[ :id ])
    image.update_attributes(image_attributes)
    image
  end

  def update_attributes_by_create(image_attributes)
    Image.create!(image_attributes.update(:batch_id => self.id))
  end

  def update_attributes_by_delete(image_attributes)
    image = image_for_id!(image_attributes[ :id ])
    image.destroy
    image
  end

  def image_for_id!(image_id)
    Image.by_batch_and_image_id(self, image_id).first or raise ActiveRecord::RecordNotFound, "Cannot find image #{ image_id }"
  end

  def self.event_type_from_parameters(parameters)
    case
    when !parameters[ :delete ].blank? then :delete
    when parameters[ :data ].blank?    then nil
    when !parameters.key?(:id)         then :create
    else :update
    end
  end

  class Sample
    attr_reader :batch
    attr_reader :lane
    attr_reader :name

    def initialize(batch, lane, name)
      @batch, @lane, @name = batch, lane, name
    end

    def image(side, &block)
      images = @batch.images.inject([ nil ] * 16) { |images,image| images[ image.position ] = image ; images }
      image = images[ self.image_index_for_side(side) ]
      yield(image) unless image.nil?
    end

    def image_index_for_side(side)
      index = (self.lane-1) * 2
      index = index + 1 if side == :right
      index
    end

    def same_as?(sample)
      self.name == sample.name
    end
  end

  class LaneForComparison
    attr_reader :batch
    attr_reader :lane

    def initialize(details)
      @batch, @lane = Batch.find(batch_id = details[ :id ]), details[ :lane ].to_i
    rescue ActiveResource::ResourceNotFound => exception
      raise Batch::BatchNotFound.new(batch_id)
    end

    def sample
      @batch.samples.find { |sample| sample.lane == @lane }
    end

    def ==(lane)
      (self.batch == lane.batch) and (self.lane == lane.lane)
    end
    alias_method :eql?, :==

    def hash
      [ self.batch, self.lane ].hash
    end
  end
end
