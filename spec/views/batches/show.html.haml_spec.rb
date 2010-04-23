require 'spec_helper'
require 'ostruct'

describe '/batches/show' do
  before(:each) do
    assigns[ :batch ] = batch = mock_model(Batch, :id => 9999)
    batch.errors.stub!(:[]).with(:image).and_return(nil)
    render :action => 'batches/show'
  end
  
  it 'renders a form to upload an image' do
    response.should put_form_to(batch_update_path(:id => '9999'))
  end
end