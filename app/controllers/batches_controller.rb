class BatchesController < ApplicationController

  def show
    begin
      @batch = Batch.find(params[:id])
    rescue(ActiveResource::ResourceNotFound)
      @batch_number = params[:id]
      render :batch_not_found
    end    
  end
  
end
