# Responsible for handling requests related to Batch instances, this controller is the main hub
# of the application.
#
# Supports the following actions:
#
#   thumbnail => sends back the image thumbnail data for image_id
#   image     => sends back the original image data for image_id
class BatchesController < ApplicationController
  before_filter :require_user
  
  public :send_data  # Open #send_data so that it can called from Image.
  
  class << self
    def handles_with_batch_not_found(action, &block)  
      define_method(action) { handle_with_batch_not_found(&block) }
    end

    def define_action_to_send_the(part, options = {})
      define_method(part) do
        Image.find(params[:image_id]).send(:"send_#{ part }_data_via", self, options)
      end
    end
  end

  def index
    # Do nothing and fall through to the view
  end

  handles_with_batch_not_found(:show)
  
  handles_with_batch_not_found(:update) do
    @batch.update_attributes(params[ :batch ]) do |event,image|
      @events.push(translate("batches.messages.image_upload.#{ event }", :data_file_name => image.data_file_name))
    end
  end
  
  define_action_to_send_the(:thumbnail, :disposition => 'inline')
  define_action_to_send_the(:image)
  
private

  def handle_with_batch_not_found(&block)
    @batch_number = params[ :id ]
    @events, @batch = [], Batch.find(@batch_number)
    instance_eval(&block) if block_given?
    render :show
  rescue ActiveResource::ResourceNotFound => exception
    flash[:error] = translate('batches.errors.batch_not_found', :batch_id => @batch_number)
    redirect_to batches_path
  end

end
