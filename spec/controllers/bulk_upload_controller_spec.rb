require 'spec_helper'

describe BulkUploadController do
  include BatchHelper

  check_routing do
    routing_to('/bulk_upload/start', { :action => 'start' }, RoutingHelper::HTTP_GET_ONLY)
    routing_to('/bulk_upload/start/456', { :action => 'start', :id => '456' }, RoutingHelper::HTTP_GET_ONLY)
    routing_to('/bulk_upload/123/cancel', { :action => 'cancel', :id => '123' }, RoutingHelper::HTTP_GET_ONLY)
    routing_to('/bulk_upload/123/upload', { :action => 'upload', :id => '123' }, RoutingHelper::HTTP_PUT_ONLY)
    routing_to('/bulk_upload/123/finish/456', { :action => 'finish', :id => '123', :batch_id => '456' }, RoutingHelper::HTTP_GET_ONLY)
  end

  context "GET 'start'" do
    context 'without a batch ID specified' do
      before(:each) do
        get :start
      end

      it 'assigns @bulk_upload' do
        assigns[ :bulk_upload ].should_not be_nil
      end

      it 'renders the view without a layout' do
        response.should render_template('start')
      end
    end

    context 'with a batch ID specified' do
      before(:each) do
        get :start, :id => BatchHelper::VALID_BATCH_ID
      end

      it 'assigns @batch' do
        assigns[ :batch ].should_not be_nil
      end
    end
  end

  context "PUT 'upload'" do
    before(:each) do
      @bulk_upload = BulkUpload.create!

      put :upload, :id => @bulk_upload.id, :data => 'image data'
    end

    it 'must render some non-blank text for YUI Uploader to work' do
      response.body.should match(/[^\s]+/)
    end

    it 'has a 200 OK response' do
      response.status.should == '200 OK'
    end
  end

  context "GET 'finish'" do
    before(:each) do
      @bulk_upload = BulkUpload.create!

      get :finish, :id => @bulk_upload.id, :batch_id => BatchHelper::VALID_BATCH_ID
    end

    it 'redirects to the path for the batch' do
      response.should redirect_to(batch_path(:id => BatchHelper::VALID_BATCH_ID))
    end

    it 'sets a flash[:message]' do
      flash[:message].should_not be_blank
    end
  end

  context "GET 'cancel'" do
    before(:each) do
      @bulk_upload = BulkUpload.create!

      get :cancel, :id => @bulk_upload.id
    end

    it 'destroys the instance' do
      lambda { @bulk_upload.reload }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it 'redirects to the batches path' do
      response.should redirect_to(batches_path)
    end

    it 'sets a flash[:message]' do
      flash[:message].should_not be_blank
    end
  end
end
