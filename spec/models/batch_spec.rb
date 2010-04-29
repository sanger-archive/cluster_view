require 'spec_helper'

class Batch
  public :update_attributes_by_update
  public :update_attributes_by_create
  public :update_attributes_by_delete
end

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

    it 'does not update or create an image if no image data is uploaded' do
      Image.should_receive(:create!).with(any_args).never

      callback = mock('callback')
      callback.should_receive(:called_with).with(any_args).never

      # This is missing :data parameter
      @batch.update_attributes(:images => { '0' => { } }) do |*args|
        callback.called_with(*args)
      end
    end

    shared_examples_for('acting upon an image') do
      it 'performs the correct image update' do
        @batch.update_attributes(:images => { '0' => @attributes.update(:filename => 'filename', :data => "image data") })
      end

      it 'yields the event type and image when the block is given' do
        callback = mock('callback')
        callback.should_receive(:called_with).with(@event, :image)

        @batch.update_attributes(:images => { '0' => @attributes.update(:filename => 'filename', :data => "image data") }) do |*args|
          callback.called_with(*args)
        end
      end
    end

    context 'updating an existing image' do
      before(:each) do
        @batch.should_receive(:update_attributes_by_update).with(hash_including(:id => 'ID')).and_return(:image)
        @attributes, @event = { :id => 'ID' }, :update
      end

      it_should_behave_like('acting upon an image')
    end

    context 'creating a new image' do
      before(:each) do
        @batch.should_receive(:update_attributes_by_create).with(any_args).and_return(:image)
        @attributes, @event = { }, :create
      end

      it_should_behave_like('acting upon an image')
    end

    context 'deleting an existing image' do
      before(:each) do
        @batch.should_receive(:update_attributes_by_delete).with(hash_including(:id => 'ID')).and_return(:image)
        @attributes, @event = { :id => 'ID', :delete => 'yes' }, :delete
      end

      it_should_behave_like('acting upon an image')

      it 'deletes the image even if the image data is not sent' do
        callback = mock('callback')
        callback.should_receive(:called_with).with(@event, :image)

        @batch.update_attributes(:images => { '0' => @attributes.update(:filename => 'filename') }) do |*args|
          callback.called_with(*args)
        end
      end
    end
  end

  describe '#update_attributes_by_update' do
    it 'updates an existing Image instance' do
      image = mock('image')
      image.should_receive(:update_attributes).with(:id => 'IMAGE ID', :filename => 'foo', :position => '1', :data => 'image data')
      Image.should_receive(:by_batch_and_image_id).with(@batch, 'IMAGE ID').and_return([ image ])

      @batch.update_attributes_by_update(:id => 'IMAGE ID', :filename => 'foo', :data => "image data", :position => '1').should == image
    end
  end

  describe '#update_attributes_by_create' do
    it 'creates a new Image instance' do
      Image.should_receive(:create!).with(
        :batch_id => BatchHelper::VALID_BATCH_ID, :position => '0',
        :filename => 'foo', :data => 'image data'
      ).and_return(:ok)

      @batch.update_attributes_by_create(:filename => 'foo', :data => "image data", :position => '0').should == :ok
    end
  end

  describe '#update_attributes_by_delete' do
    it 'destroys the Image instance' do
      image = mock('image')
      image.should_receive(:destroy)
      Image.should_receive(:by_batch_and_image_id).with(@batch, 'IMAGE ID').and_return([ image ])

      @batch.update_attributes_by_delete(:id => 'IMAGE ID', :data => 'image data', :delete => 'yes').should == image
    end
  end
end
