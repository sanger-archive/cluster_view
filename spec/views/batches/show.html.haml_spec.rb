require 'spec_helper'
require 'ostruct'

describe '/batches/show' do
  def render_partial
    assigns[ :batch ] = @batch = mock_model(Batch, :id => 9999, :status => 'Released')
    @batch.errors.stub!(:[]).with(:image).and_return(nil)
    @batch.stub!(:images).and_return(@images)
    @batch.stub!(:samples).and_return(@samples)

    render :action => 'batches/show'
  end

  context 'with images' do
    before(:each) do
      @images = (1..5).map { |index| mock_model(Image, :id => index, :data_file_name => ("%03i" % index), :batch_id => 9999, :position => index-1) }
      @samples = (1..3).map { |index| mock('sample', :lane => index, :name => "Sample #{ index }") }
      render_partial
    end

    it 'renders the thumbnails' do
      response.should have_tag('#thumbnails') do |thumbnails|
        @images.each do |image|
          thumbnails.should have_tag('img', :src => batch_thumbnail_path(:id => @batch.id, :image_id => image.id))
        end
      end
    end
  end

  context 'without images' do
    before(:each) do
      @images = @samples = []
      render_partial
    end

    it 'does not render thumbnail images' do
      response.should have_tag('#thumbnails', /^\s*$/)
    end

    it 'renders a form to upload an image' do
      response.should put_form_to(batch_update_path(:id => '9999'), :enctype => 'multipart/form-data')
    end

    it 'displays the status of the batch' do
      response.should have_tag('.status', 'Released')
    end
  end
end
