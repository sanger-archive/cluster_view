require 'spec_helper'

class BulkUpload
  public :complete_for_batch
end

describe BulkUpload do
  include BatchHelper

  before(:each) do
    @bulk_upload = described_class.create!
  end

  describe '#upload_data' do
    it 'creates an appropriate image instance' do
      @bulk_upload.upload_data(nil)
      Image.for_bulk_upload(@bulk_upload).all.should_not be_empty
    end

    it 'sets the position of the image to the count of the associated images' do
      @bulk_upload.stub!(:images).and_return((0..10).to_a)
      @bulk_upload.upload_data(nil)
      Image.for_bulk_upload(@bulk_upload).in_position(11).all.should_not be_empty
    end

    it 'allows the position to be specified' do
      @bulk_upload.upload_data(nil, 14)
      Image.for_bulk_upload(@bulk_upload).in_position(14).all.should_not be_empty
    end

    context 'with existing images present' do
      before(:each) do
        @original = Image.create!(:bulk_upload_id => @bulk_upload.id, :position => 9)
        @bulk_upload.upload_data(nil, 9)
      end
      
      subject { Image.for_bulk_upload(@bulk_upload).in_position(9).all }

      it 'destroys any Image instances that may already exist at the position' do
        subject.should_not include(@original)
      end

      it 'still creates the new Image instance' do
        subject.length.should == 1
      end
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
  
  describe "#numeric_from_filename" do
    before(:each) do
      class ImagesExtensionDummy
        include BulkUpload::ImagesExtension
      end
      
      @images_extension_dummy = ImagesExtensionDummy.new
    end
    
    it "returns 12 from a filename of 'IMAGE012.Tif'" do
      @images_extension_dummy.numeric_from_filename('IMAGE012.Tif').should == 12
    end
    
    it "returns 12 from a filename of '12.Tif'" do
      @images_extension_dummy.numeric_from_filename('12.Tif').should == 12
    end
    
    it "raise an exception if the filename doesn't contain a number" do
      lambda {
        @images_extension_dummy.numeric_from_filename('NOT_A_NUMBER.tiff')
      }.should raise_error
    end
    
    
  end
end
