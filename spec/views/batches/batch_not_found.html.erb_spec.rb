require 'spec_helper'

describe '/batches/batch_not_found' do
  before(:each) do
    assigns[ :batch_number ] = 'BATCH NUMBER'
    render :action => 'batches/batch_not_found'
  end
  
  it 'displays the batch number' do
    response.should contain('BATCH NUMBER')
  end
end