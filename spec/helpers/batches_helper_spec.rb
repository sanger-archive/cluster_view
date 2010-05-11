require 'spec_helper'

describe BatchesHelper do
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
end
