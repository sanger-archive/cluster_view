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

  describe '#samples' do
    def sample(index, &block)
      @batch.samples[ index ].tap(&block)
    end

    it 'deals with control samples' do
      sample(3) do |sample|
        sample.lane.should == 4
        sample.name.should == 'control sample'
      end
    end

    it 'deals with library samples' do
      sample(0) do |sample|
        sample.lane.should == 1
        sample.name.should == 'sample from library 1'
      end
    end
  end
  
  describe '#update_attributes' do
    it 'does not update the images (or fall over) if the parameter is unspecified' do
      Image.should_receive(:create!).never
      Image.should_receive(:find).never
      
      @batch.update_attributes({})
    end

    context 'not uploading an image' do
      after(:each) do
        Image.should_receive(:create!).with(any_args).never

        callback = mock('callback')
        callback.should_receive(:called_with).with(any_args).never

        @batch.update_attributes(:images => { '0' => @image_attributes }) do |*args|
          callback.called_with(*args)
        end
      end

      it 'does nothing if the image data is empty' do
        @image_attributes = { :filename => 'foo' }
      end

      it 'does nothing if the filename is blank' do
        @image_attributes = { :filename => '', :data => 'some random data' }
      end
    end

    context 'creating a new image' do
      before(:each) do
        @update_params = { :images => { '0' => { :filename => 'foo', :data => StringIO.new('image data') } } }

        Image.should_receive(:create!).with(
          :batch_id => BatchHelper::VALID_BATCH_ID, :position => '0',
          :filename => 'foo', :data => 'image data'
        ).and_return(:ok)
      end
    
      it 'creates a new image if the :id is unspecified' do
        @batch.update_attributes(@update_params)
      end
    
      it 'yields the event and the image' do
        callback = mock('callback')
        callback.should_receive(:called_with).with(:created, :ok)

        @batch.update_attributes(@update_params) { |*args| callback.called_with(*args) }
      end
    end

    context 'updating an existing image' do
      before(:each) do
        @update_params = { :images => { '1' => { :id => 'IMAGE ID', :filename => 'foo', :data => StringIO.new('image data') } } }

        @image = mock('image')
        @image.should_receive(:update_attributes).with(:id => 'IMAGE ID', :filename => 'foo', :position => '1', :data => 'image data')
        Image.should_receive(:by_batch_and_image_id).with(@batch, 'IMAGE ID').and_return(@image)
      end
    
      it 'updates the details of an image if the :id is specified' do
        @batch.update_attributes(@update_params)
      end

      it 'yields the event and the image' do
        callback = mock('callback')
        callback.should_receive(:called_with).with(:updated, @image)

        @batch.update_attributes(@update_params) { |*args| callback.called_with(*args) }
      end
    end

    it 'uses removes extraneous path information from the filename' do
      Image.should_receive(:create!).with(
        :batch_id => BatchHelper::VALID_BATCH_ID, :position => '0',
        :filename => 'foo', :data => 'image data'
      ).and_return(:ok)

      @batch.update_attributes({ :images => { '0' => { :filename => 'dir1/dir2/foo', :data => StringIO.new('image data') } } })
    end
  end
end
