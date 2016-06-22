# Responsible for handling requests related to Batch instances, this controller is the main hub
# of the application.
#
# Supports the following actions:
#
#   thumbnail => sends back the image thumbnail data for image_id
#   image     => sends back the original image data for image_id
class BatchesController < ApplicationController
  before_filter :require_user
  before_filter Filters::ConvertArrayParameter(:lanes), :only => :compare
  before_filter Filters::ConvertArrayParameter(:batch, :images), :only => :update
  before_filter Filters::PrepareObjectFilter(Batch, :id), :only => [ :show, :update ]
  before_filter Filters::PrepareObjectFilter(Image, :image_id), :only => [ :image, :thumbnail ]
  before_filter :needs_events, :only => [ :show, :update ]

  def index
    # Do nothing and fall through to the view
  end

  def show
    # Do nothing and fall through to the view
  end

  def update
    if params[:batch].nil?
      flash[:error] = translate('batches.errors.empty_submission', :batch_id => @batch.id)
	    redirect_to(batch_path(@batch))
    else
      @batch.update_attributes(params[ :batch ]) do |event,image|
        @events.push(translate("batches.messages.image_upload.#{ event }", :data_file_name => image.data_file_name))
      end
      render :show
    end
  end

  def thumbnail
    @image.send_thumbnail_data_via(to_image_sending_facade, :disposition => 'inline')
  end

  def image
    @image.send_image_data_via(to_image_sending_facade)
  end

  def compare
    @lanes = params[ :lanes ].map { |details| Batch::LaneForComparison.new(details) }.uniq

    if @lanes.size == 1
      flash[:error] = translate('batches.messages.comparison.identical_lanes')
      redirect_to root_path
    elsif not @lanes.all? { |lane| lane.sample.same_as?(@lanes.first.sample) }
      flash[:warning] = translate('batches.messages.comparison.different_samples')
    end
  rescue Batch::BatchNotFound => exception
    flash[:error] = translate('batches.errors.batch_not_found', :batch_id => exception.batch_id)
    redirect_to root_path
  end

private

  def handle_batch_not_found_for(batch_id)
    flash[:error] = translate('batches.errors.batch_not_found', :batch_id => batch_id)
    redirect_to root_path
  end

  def handle_batch_timeout(batch_id)
    flash[:error] = translate('batches.errors.timeout', :batch_id => batch_id)
    redirect_to root_path
  end

  def needs_events
    @events = []
  end

  def handle_image_not_found_for(image_id)
    # Because the image is sent back to the browser we cannot simply redirect like we normally would
    # so we have to send back a simple '404 Not Found' response.
    render :text => ' ', :status => :not_found
  end

  def to_image_sending_facade
    ImageSendingFacade.new(self)
  end

  # This is a facade that provides the interface required by the image sending code
  class ImageSendingFacade
    def initialize(controller)
      @controller = controller
    end

    def error_as_no_data_for(image)
      @controller.render :text => '', :status => :not_found
    end

    def send_data(*args, &block)
      @controller.send(:send_data, *args, &block)
    end
  end
end
