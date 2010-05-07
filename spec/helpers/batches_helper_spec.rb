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
    it 'generates the appropriate output' do
      helper.should_receive(:hidden_field_tag).with("batch[images][11][id]", 'ID').and_return('ID_FIELD')
      helper.should_receive(:file_field_tag).with("batch[images][11][data]").and_return('FILE_FIELD')
      helper.should_receive(:labeled_check_box_tag).with("batch[images][11][delete]", "Delete image FOO.tif").and_return('CHECK_BOX')

      sample = mock('sample', :lane => 1)
      sample.stub!(:image_index_for_side).with(:random_side).and_return(11)

      output = helper.image_upload_tag(:random_side, sample, mock('image', :id => 'ID', :root_filename => 'FOO.tif'))
      output.should == [ 'FILE_FIELD', 'CHECK_BOX', 'ID_FIELD' ].join("\n")
    end
  end
end
