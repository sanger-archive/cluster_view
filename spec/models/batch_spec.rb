require 'spec_helper'

describe Batch do
  include BatchHelper
  
  before(:each) do
    @batch = Batch.find(BatchHelper::VALID_BATCH_ID)
  end

  describe '#images' do
    it 'finds all Image instances associated with the batch' do
      Image.should_receive(:for_batch).with(@batch).and_return(:ok)
      @batch.images.should == :ok
    end
  end
  
  describe '#update_attributes' do
    it 'does not update the images (or fall over) if the parameter is unspecified' do
      Image.should_receive(:create!).never
      Image.should_receive(:find).never
      
      @batch.update_attributes({})
    end
    
    it 'creates a new image if the :id is unspecified' do
      Image.should_receive(:create!).with(:batch_id => BatchHelper::VALID_BATCH_ID, :filename => 'foo')
      
      @batch.update_attributes(:images => [ { :filename => 'foo' } ])
    end
    
    it 'updates the details of an image if the :id is specified' do
      image = mock('image')
      image.should_receive(:update_attributes).with(:id => 'IMAGE ID', :filename => 'foo')
      Image.should_receive(:by_batch_and_image_id).with(@batch, 'IMAGE ID').and_return(image)
      
      @batch.update_attributes(:images => [ { :id => 'IMAGE ID', :filename => 'foo' } ])
    end
  end
end
