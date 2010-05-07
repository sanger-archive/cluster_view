require 'spec_helper'

class BulkUpload
  public :complete_for_batch
end

describe BulkUpload do
  before(:each) do
    @bulk_upload = described_class.create!
  end

  it 'has many images ordered by data_file_name ASC'

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
      @batch = mock('Batch', :id => 'batch id')
    end

    after(:each) do
      @bulk_upload.complete_for_batch(@batch)
    end

    def mock_images(&block)
      (0..2).inject([]) do |array,index|
        image = mock("image #{ index }")
        yield(image, index)
        array << image
      end
    end

    it 'destroys the Image instances associated with the Batch' do
      images = mock_images { |image,_| image.should_receive(:destroy) }
      @batch.stub!(:images).and_return(images)
    end

    it 'updates the associated Image instances' do
      images = mock_images do |image,index|
        image.should_receive(:update_attributes).with(hash_including(:batch_id => @batch.id, :bulk_upload_id => nil, :position => index))
      end
      @batch.stub!(:images).and_return([])
      @bulk_upload.stub!(:images).and_return(images)
    end
  end
end
