require 'spec_helper'

describe '/batches/batch_not_found' do
  before(:each) do
    render :action => 'batches/batch_not_found'
  end
  
  it 'displays a failure message' do
    response.should have_tag('h1')
  end
end
