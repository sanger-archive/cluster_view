class BulkUploadController < ApplicationController
  # NOTE[md12]: Unfortunately the Flash upload tool does not support sending cookies so the forgery
  # protection stuff needs to be disable for this controller.
  protect_from_forgery :except => [ :start, :upload, :finish, :cancel ] if allow_forgery_protection && request_forgery_protection_token

  before_filter Filters::PrepareObjectFilter(BulkUpload, :id), :only => [ :upload, :finish, :cancel ]
  before_filter Filters::PrepareObjectFilter(Batch, :id), :only => [ :start ], :if => :batch_id_specified?

  # Called by Ajax to start a bulk upload.  It creates a BulkUpload instance and returns the necessary
  # HTML that can be displayed to pick for that upload
  def start
    @bulk_upload = BulkUpload.create!
    render :layout => false
  end

  # Each image that is uploaded comes through this action from the Flash upload tool.  They are simply
  # attached to the BulkUpload instance and we return OK or error.
  def upload
    contents = {:file => params[:data]}
    @bulk_upload.upload_data(contents, params[ :index ])
    render :text => 'DONE', :status => 200  # NOTE[md12]: Send back at least 1 non-whitespace byte for YUI Uploader to work!
  end

  # When the last image has been uploaded the browser is directed to view this action, which completes
  # the BulkUpload instance and then redirects the browser to the Batch view.
  def finish
    batch = @bulk_upload.complete_for_batch!(params[ :batch_id ])
    flash[ :message ] = translate('bulk_upload.messages.completed', :id => @bulk_upload.id, :batch_id => batch.id)
    redirect_to batch_path(batch)
  end

  # This action handles cancelling a bulk upload *before* any files are being uploaded.  It does not
  # handle doing it during an upload.
  def cancel
    @bulk_upload.destroy
    flash[ :message ] = translate('bulk_upload.messages.cancelled', :id => @bulk_upload.id)
    redirect_to batches_path
  end

private

  def handle_bulk_upload_not_found_for(bulk_upload_id)
    if request.xhr?
      render :text => ' ', :status => :not_found
    else
      flash[ :error ] = translate('bulk_upload.errors.not_found', :id => bulk_upload_id)
      redirect_to batches_path
    end
  end

  def batch_id_specified?
    not params[ :id ].blank?
  end

  def handle_batch_not_found_for(batch_id)
    if request.xhr?
      render :text => ' ', :status => :internal_server_error
    else
      flash[ :error ] = translate('batches.errors.batch_not_found', :batch_id => batch_id)
      redirect_to batches_path
    end
  end
end
