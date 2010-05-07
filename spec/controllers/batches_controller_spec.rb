require 'spec_helper'

shared_examples_for('the batch is invalid') do
  it 'renders batch not found' do
    response.should redirect_to(batches_path)
  end
  
  it "sets the flash[:error]" do
    flash[:error].should_not be_nil
  end
end

describe BatchesController do
  include BatchHelper

  check_routing do
    routing_to('/thumbnails/271/1', { :action => 'thumbnail', :id => '271', :image_id => '1' }, RoutingHelper::HTTP_GET_ONLY)
    routing_to('/images/1000/200', { :action => 'image', :id => '1000', :image_id => '200' }, RoutingHelper::HTTP_GET_ONLY)
  end

  before(:each) do
    log_in_user('John Smith')
  end
  
  context "GET 'show'" do
    context 'when the batch is valid' do
      before(:each) do
        get 'show', :id => BatchHelper::VALID_BATCH_ID
      end
      
      it 'assigns the batch for the view' do
        assigns[ :batch ].should_not be_nil
      end
    end
    
    context 'when the batch is invalid' do
      before(:each) do
        get 'show', :id => BatchHelper::INVALID_BATCH_ID
      end
      
      it_should_behave_like 'the batch is invalid'
    end
  end
  
  context "PUT 'update'" do
    def self.performs_update_with_id(id)
      before(:each) do
        put 'update', :id => id, :batch => { :images => { '0' => { :data => StringIO.new('image data') } } }
      end
    end
    
    context 'when the batch is valid' do
      performs_update_with_id(BatchHelper::VALID_BATCH_ID)
      
      it 'assigns the batch for the view' do
        assigns[ :batch ].should_not be_nil
      end

      it 'assigns the events that have occurred' do
        assigns[ :events ].should_not be_empty
      end
    end
    
    context "when the batch is invalid" do
      performs_update_with_id(BatchHelper::INVALID_BATCH_ID)
      it_should_behave_like 'the batch is invalid'
    end
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end
  
  context "when downloading images from clusterview" do
    describe "GET 'image' to download original tiff images" do
      before(:each) do
        @image = Factory('Images for batch', :batch_id => BatchHelper::VALID_BATCH_ID)
      end
      
      def do_get_image_file
        get :image, :id => BatchHelper::VALID_BATCH_ID, :image_id => @image.id
      end
      
      it "returns an image with the original image's MIME type." do
        do_get_image_file()
        response.content_type.should == @image.data_content_type
      end
    
      it 'responds with some image data' do
        do_get_image_file()
        response.body.to_s.should_not be_empty
      end

      it 'does not put the filename in the response body!' do
        do_get_image_file()
        response.body.to_s.should_not == "/images/#{@image.data_file_name}"
      end
    
      it "doesn't return the thumbnail instead of the original image." do
        do_get_image_file()
        response.body.to_s.should_not == @image.data_thumbnail_file.to_s
      end
      
      it "returns the original image with the correct filename." do
        controller.should_receive(:send_data).with(
          @image.data_file,
          :filename => @image.data_file_name,
          :type => @image.data_content_type)
          
        do_get_image_file()
      end
    end
    
    describe "GET 'thumbnail' to download JPEG thumbnails" do
      before(:each) do
        @image = Factory('Images for batch', :batch_id => BatchHelper::VALID_BATCH_ID)
        get :thumbnail, :id => BatchHelper::VALID_BATCH_ID, :image_id => @image.id
      end

      it 'responds with the thumbnail MIME type' do
        response.content_type.should == Image::DATA_THUMBNAIL_CONTENT_TYPE
      end

      it 'responds with some image data' do
        response.body.to_s.should_not be_empty
      end

      it 'does not put the filename in the response body!' do
        response.body.to_s.should_not == "/thumbnails/#{BatchHelper::VALID_BATCH_ID}/#{@image.id}"
      end
    end
  end

end
