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
  
  describe "#image_number" do
    it "returns 1 for an image in lane 8 on the right hand side." do
      helper.image_number(:right,8).should == 1
    end
    
    it "returns 8 for an image in lane 1 on the right hand side" do
      helper.image_number(:right,1).should == 8
    end
    
    it "returns 9 for an image in lane 1 on the left hand side" do
      helper.image_number(:left,1).should == 9
    end
    
    it "returns 16 for an image in lane 8 on the left hand side" do
      helper.image_number(:left,8).should == 16
    end
  end
end
