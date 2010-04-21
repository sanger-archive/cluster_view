class BatchesController < ApplicationController

  def show
    begin
      @batch = Batch.find(params[:id])
    rescue(ActiveResource::ResourceNotFound)
      render :batch_not_found
    end    
  end
  
end
