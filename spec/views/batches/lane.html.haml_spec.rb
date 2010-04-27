require 'spec_helper'

describe '/batches/_lane.html' do
  before(:each) do
    sample = mock('sample', :lane => 1234, :name => 'Sample 5678')

    left_image = mock('left image', :id => 2222)
    template.should_receive(:thumbnail_for).with(sample, left_image, :left).and_return('<left_thumbnail/>')

    right_image = mock('right image', :id => 3333)
    template.should_receive(:thumbnail_for).with(sample, right_image, :right).and_return('<right_thumbnail/>')

    render(
      :partial => 'batches/lane', 
      :locals => { 
        :sample => sample,
        :left => left_image,
        :right => right_image
      }
    )
  end

  it 'uniquely identifies the lane' do
    response.should have_tag('#lane_1234.lane')
  end

  it 'reports the lane number' do
    response.should have_tag('.details .lane', '1234')
  end

  it 'reports the sample' do
    response.should have_tag('.details .sample', 'Sample 5678')
  end
end
