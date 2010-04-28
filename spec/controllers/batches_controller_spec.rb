require 'spec_helper'

shared_examples_for('the batch is invalid') do
  it 'renders batch not found' do
    response.should render_template('batch_not_found')
  end
  
  it "sets the flash[:error]" do
    flash[:error].should_not be_nil
  end
end

shared_examples_for('returns batch image data') do
  before(:each) do
    image = Factory('Images for batch', :batch_id => BatchHelper::VALID_BATCH_ID)
    get(controller_action(), :id => BatchHelper::VALID_BATCH_ID, :image_id => image.id)
  end

  it 'responds with a JPEG MIME type' do
    response.content_type.should == 'image/jpeg'
  end

  it 'responds with some image data' do
    response.body.to_s.should_not be_empty
  end

  it 'does not put the filename in the response body!' do
    response.body.to_s.should_not == '/images/2617.jpg'
  end
end

describe BatchesController do
  include BatchHelper

  check_routing do
    routing_to('/thumbnails/271/1', { :action => 'thumbnail', :id => '271', :image_id => '1' }, RoutingHelper::HTTP_GET_ONLY)
    routing_to('/images/1000/200', { :action => 'image', :id => '1000', :image_id => '200' }, RoutingHelper::HTTP_GET_ONLY)
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
        put 'update', :id => id, :batch => { :images => { '0' => { :data => StringIO.new('image data'), :filename => 'my filename' } } }
      end
    end
    
    context 'when the batch is valid' do
      performs_update_with_id(BatchHelper::VALID_BATCH_ID)
      
      it 'assigns the batch for the view' do
        assigns[ :batch ].should_not be_nil
      end

      it 'sets the flash[:events]' do
        flash[ :events ].should_not be_empty
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

  describe "GET 'thumbnail'" do
    def controller_action
      'thumbnail'
    end

    it_should_behave_like 'returns batch image data'
  end

  describe "GET 'image'" do
    def controller_action
      'image'
    end

    it_should_behave_like 'returns batch image data'
  end
end
