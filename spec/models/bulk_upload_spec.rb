require 'spec_helper'

class BulkUpload
  public :complete_for_batch
end

describe BulkUpload do
  before(:each) do
    @bulk_upload = described_class.create!
  end

  describe '#upload_data' do
    after(:each) do
      Image.should_receive(:create!).with(hash_including(
        :bulk_upload_id => @bulk_upload.id, 
        :data           => :source, 
        :position       => @expected_position
      )).and_return(:image)

      @bulk_upload.upload_data(:source).should == :image
    end

    it 'creates an Image instance' do
      @expected_position = 0
    end

    it 'sets the position of the image to the count of the associated images' do
      @bulk_upload.stub!(:images).and_return((1..10).to_a)
      @expected_position = 10
    end
  end

  describe '#complete_for_batch!' do
    before(:each) do
      Batch.should_receive(:find).with(:id).and_return(:batch)
      @bulk_upload.should_receive(:complete_for_batch).with(:batch).and_return(:completed_batch)
    end

    it 'destroys the instance' do
      @bulk_upload.complete_for_batch!(:id)
      @bulk_upload.should be_destroyed
    end

    it 'returns the batch' do
      @bulk_upload.complete_for_batch!(:id).should == :completed_batch
    end
  end

  describe '#complete_for_batch' do
    before(:each) do
      @batch = Batch.find(BatchHelper::VALID_BATCH_ID)
      @bulk_upload = Factory('Bulk upload')
      @bulk_upload.complete_for_batch(@batch)
    end

    it 'updates the associated Image instances to be in the correct order' do
      @batch.images.inject([]) { |a,image| a[ image.position ] = image.data_file_name ; a }.should == [
        "7.tif", "8.tif", 
        "6.tif", "9.tif", 
        "5.tif", "10.tif", 
        "4.tif", "11.tif", 
        "3.tif", "12.tif", 
        "2.tif", "13.tif", 
        "1.tif", "14.tif", 
        "0.tif", "15.tif"
      ]
    end
  end
end
