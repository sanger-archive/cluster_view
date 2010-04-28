require 'spec_helper'

describe BatchesHelper do
  describe '#lane_organised_images_for' do
    it 'yield the images in pairs' do
      batch = mock('batch', :id => 12345)
      images = (1..5).map { |index| Factory('Images for batch', :batch_id => 12345, :position => index-1) }
      samples = (1..3).map { |index| mock("Sample #{ index }", :lane => index, :name => "Sample #{ index }") }
      batch.stub!(:images).and_return(images)
      batch.stub!(:samples).and_return(samples)

      callback = mock('callback')
      callback.should_receive(:called_with).with(samples[ 0 ], images[ 0 ], images[ 1 ])
      callback.should_receive(:called_with).with(samples[ 1 ], images[ 2 ], images[ 3 ])
      callback.should_receive(:called_with).with(samples[ 2 ], images[ 4 ], nil)

      helper.lane_organised_images_for(batch) { |*args| callback.called_with(*args) }
    end
  end

  describe '#thumbnail_for' do
    it 'passes through to the batches/thumnail partial' do
      helper.should_receive(:render).with(:partial => 'batches/thumbnail', :locals => { :sample => 'sample', :image => 'image', :side => 'side' }).and_return(:ok)
      helper.thumbnail_for('sample', 'image', 'side').should == :ok
    end
  end

  describe '#link_to_full_size_image' do
    it 'returns a link to the image' do
      helper.link_to_full_size_image(mock_model(Image, :id => 1234, :filename => 'filename foo', :batch_id => 5678)).should ==
        helper.link_to(h('filename foo'), batch_image_path(:id => 5678, :image_id => 1234))
    end
  end

  describe '#status_of' do
    it 'returns the localised status value' do
      helper.should_receive(:translate).with('batches.statuses.foobar').and_return('localised status')
      helper.status_of(mock('batch', :status => 'foobar')).should == 'localised status'
    end
  end

  describe '#image_upload_tag' do
    after(:each) do
      helper.should_receive(:hidden_field_tag).with("root[#{ @index }][id]", 'ID').and_return('ID_FIELD')
      helper.should_receive(:file_field_tag).with("root[#{ @index }][data]").and_return('FILE_FIELD')

      helper.image_upload_tag('root', @side, mock('sample', :lane => @lane), mock('image', :id => 'ID')).should == "ID_FIELD\nFILE_FIELD"
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
end
