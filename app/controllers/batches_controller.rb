class BatchesController < ApplicationController
  class << self
    def handles_with_batch_not_found(action, &block)  
      define_method(action) do
        begin
          @batch = Batch.find(params[:id])
          instance_eval(&block) if block_given?
          render :show
        rescue ActiveResource::ResourceNotFound => exception
          @batch_number = params[:id]
          flash[:error] = "Batch #{params[:id]} could not be found."
          render :batch_not_found
        end
      end
    end
  end

  handles_with_batch_not_found(:show)
  
  handles_with_batch_not_found(:update) do
    @batch.update_attributes(params[:batch])

    flash[:message] = "Image 2617.tif uploaded successfully"
  end
end
