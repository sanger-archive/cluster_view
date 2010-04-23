require 'spec_helper'

shared_examples_for('the batch is invalid') do
  it 'renders batch not found' do
    response.should render_template('batch_not_found')
  end
  
  it "sets the flash[:error]" do
    flash[:error].should_not be_nil
  end
  
  it 'assigns @batch_number to be the batch ID' do
    assigns[ :batch_number ].should == BatchHelper::INVALID_BATCH_ID.to_s
  end
end

describe BatchesController do
  include BatchHelper
  
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
        put 'update', :id => id, :batch => { :image => :some_blob_of_data }
      end
    end
    
    context 'when the batch is valid' do
      performs_update_with_id(BatchHelper::VALID_BATCH_ID)
      
      it 'assigns the batch for the view' do
        assigns[ :batch ].should_not be_nil
      end

      it 'sets the flash[:message]' do
        flash[ :message ].should_not be_nil
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
end
