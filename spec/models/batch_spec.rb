require 'spec_helper'

class Batch
  public :update_attributes_by_update
  public :update_attributes_by_create
  public :update_attributes_by_delete
end

describe Batch do
  include BatchHelper
  
  before(:each) do
    @batch = described_class.find(BatchHelper::VALID_BATCH_ID)
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
    before(:each) do
      @callback = mock('callback')
      @attributes = { }
    end

    after(:each) do
      @batch.update_attributes(:images => { '0' => @attributes }) { |*args| @callback.called_with(*args) }
    end

    it 'does not update or create an image if the event is nil' do
      described_class.should_receive(:event_type_from_parameters).with(@attributes).and_return(nil)
      @callback.should_receive(:called_with).with(any_args).never
    end

    it 'performs the update based on the event type' do
      described_class.should_receive(:event_type_from_parameters).with(@attributes).and_return(:does_not_exist)
      @batch.should_receive(:update_attributes_by_does_not_exist).with(@attributes.merge(:position => '0')).and_return(:image)
      @callback.should_receive(:called_with).with(:does_not_exist, :image)
    end
  end

  describe '#update_attributes_by_update' do
    it 'updates an existing Image instance' do
      image = mock('image')
      image.should_receive(:update_attributes).with(:id => 'IMAGE ID', :data_file_name => 'foo', :position => '1', :data => 'image data')
      Image.should_receive(:by_batch_and_image_id).with(@batch, 'IMAGE ID').and_return([ image ])

      @batch.update_attributes_by_update(:id => 'IMAGE ID', :data_file_name => 'foo', :data => "image data", :position => '1').should == image
    end
  end

  describe '#update_attributes_by_create' do
    it 'creates a new Image instance' do
      Image.should_receive(:create!).with(
        :batch_id => BatchHelper::VALID_BATCH_ID, :position => '0',
        :data_file_name => 'foo', :data => 'image data'
      ).and_return(:ok)

      @batch.update_attributes_by_create(:data_file_name => 'foo', :data => "image data", :position => '0').should == :ok
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

  describe '.event_type_from_parameters' do
    it 'returns :delete if the :delete parameter is set' do
      described_class.event_type_from_parameters(:delete => 'yes').should == :delete
    end

    it 'returns nil if the :data parameter is blank' do
      described_class.event_type_from_parameters({}).should be_nil
    end

    it 'returns :create if the :id parameter is unspecified for :data' do
      described_class.event_type_from_parameters(:data => 'data foo').should == :create
    end

    it 'returns :update if :data and :id are specified' do
      described_class.event_type_from_parameters(:data => 'data foo', :id => 'id foo').should == :update
    end

    it 'returns :delete even when :data and :id are specified with :delete' do
      described_class.event_type_from_parameters(:data => 'data foo', :id => 'id foo', :delete => 'yes').should == :delete
    end
  end
end

describe Batch::Sample do
  before(:each) do
    @batch = mock(Batch)
  end

  describe '#image_index_for_side' do
    after(:each) do
      described_class.new(@batch, @lane, 'NAME').image_index_for_side(@side).should == @index
    end

    class << self
      def side(side)
        before(:each) do
          @side = side
        end
      end

      def lane_checks(&block)
        (1..8).map { |lane| [ lane, yield(lane) ] }.each do |lane,index|
          it "indexes lane #{ lane } as #{ index }" do
            @lane, @index = lane, index
          end
        end
      end
    end

    context 'left side images' do
      side(:left)
      lane_checks { |lane| (lane-1)*2 }
    end

    context 'right side images' do
      side(:right)
      lane_checks { |lane| (lane-1)*2 + 1 }
    end
  end

  describe '#same_as?' do
    it 'is the same if the names are equal' do
      described_class.new(@batch, 1, 'NAME').same_as?(described_class.new(@batch, 2, 'NAME')).should be_true
    end

    it 'is not the same if the names are different' do
      described_class.new(@batch, 1, 'NAME').same_as?(described_class.new(@batch, 1, 'DIFFERENT')).should be_false
    end
  end
end
