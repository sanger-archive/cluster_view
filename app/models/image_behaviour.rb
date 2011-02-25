module ImageBehaviour
  def self.included(base)
    base.class_eval do
      has_attached_file :data,
        :storage => :database, :column => "data_file",
        :styles => { :thumbnail => {:geometry => "400x400>", :format => "jpg", :column => "data_thumbnail_file"} },
        :convert_options => { :thumbnail => "-quiet -normalize" } #"-quiet" should hide warnings like "unknown field with tag"

      validates_presence_of :position
      validates_numericality_of :position, :integer_only => true
      validates_inclusion_of :position, :in => (0..15)

      validates_uniqueness_of :position, :scope => :batch_id, :if => :batch_id?

      named_scope :in_position, proc { |position|
        { :conditions => [ 'position=?', position ] }
      }
    end
  end

  # We do not need to destroy the attachments as they are part of the database, so override
  # this method to do nothing!
  def destroy_attached_files
    # Nothing to do
  end
end
