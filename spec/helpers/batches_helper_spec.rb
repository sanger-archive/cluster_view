require 'spec_helper'

describe BatchesHelper do
  describe '#thumbnail_for' do
    it 'passes through to the batches/thumnail partial' do
      helper.should_receive(:render).with(:partial => 'batches/thumbnail', :locals => { :sample => 'sample', :image => 'image', :side => 'side' }).and_return(:ok)
      helper.thumbnail_for('sample', 'image', 'side').should == :ok
    end
  end

  describe '#link_to_full_size_image' do
    it 'returns a link to the image' do
      callback = mock('callback')
      callback.should_receive(:called_with).with(any_args).and_return('content')

      helper.should_receive(:link_to).with(batch_image_path(:id => 5678, :image_id => 1234)).and_yield

      output = helper.link_to_full_size_image(mock_model(Image, :id => 1234, :data_file_name => 'filename foo', :batch_id => 5678)) do |*args|
        callback.called_with(*args)
      end
      
      output.should == 'content'
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
      helper.should_receive(:check_box_tag).with("root[#{ @index }][delete]", 'yes').and_return('CHECK_BOX')
      helper.should_receive(:label_tag).with("root[#{ @index }][delete]", 'Delete image FOO.tif').and_return('LABEL')

      output = helper.image_upload_tag('root', @side, mock('sample', :lane => @lane), mock('image', :id => 'ID', :root_filename => 'FOO.tif'))
      output.should == [ 'ID_FIELD', 'FILE_FIELD', 'CHECK_BOX', 'LABEL' ].join("\n")
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
