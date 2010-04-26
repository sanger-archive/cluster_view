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
    @batch.update_attributes(params[:batch])
    flash[:message] = translate('batches.messages.image_upload.success', :filename => '2617.tif')
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
end
