# Responsible for handling requests related to Batch instances, this controller is the main hub
# of the application.
class BatchesController < ApplicationController
  class << self
    def handles_with_batch_not_found(action, &block)  
      define_method(action) { handle_with_batch_not_found(&block) }
    end
  end

  handles_with_batch_not_found(:show)
  
  handles_with_batch_not_found(:update) do
    events = []
    @batch.update_attributes(params[ :batch ]) do |event,image|
      events.push(translate("batches.messages.image_upload.#{ event }", :data_file_name => image.data_file_name))
    end
    flash[ :events ] = events.sort
  end

  def thumbnail
    render_image(:thumbnail)
  end

  def image
    render_image(:image)
  end

private

  def handle_with_batch_not_found(&block)
    batch_number = params[ :id ]
    @batch = Batch.find(batch_number)
    instance_eval(&block) if block_given?
    render :show
  rescue ActiveResource::ResourceNotFound => exception
    flash[:error] = translate('batches.errors.batch_not_found', :batch_id => batch_number)
    render :batch_not_found
  end

  def render_image(type)
    image = Image.find(params[ :image_id ])
    send_data(image.data_thumbnail_file, :type => 'image/jpeg', :disposition => 'inline', :data_file_name => image.data_thumbnail_file_name)
  end
end
