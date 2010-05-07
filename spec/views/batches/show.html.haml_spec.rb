require 'spec_helper'
require 'ostruct'

describe '/batches/show' do
  before(:each) do
    assigns[ :batch ] = @batch = mock_model(Batch, :id => 9999, :status => 'Released')
    assigns[ :events ] = @events = []
  end

  def render_partial
    @batch.errors.stub!(:[]).with(:image).and_return(nil)
    render :action => 'batches/show'
  end

  context 'with images' do
    before(:each) do
      @batch.should_receive(:lane_organised_images).and_yield(
        Batch::Sample.new(1, 'sample name'),
        mock(Image, :id => 1, :batch_id => 9999, :position => 0, :data_file_name => "dir/000", :root_filename => '000'),
        mock(Image, :id => 2, :batch_id => 9999, :position => 1, :data_file_name => "dir/001", :root_filename => '001')
      )

      render_partial
    end

    it 'renders the thumbnails' do
      response.should have_tag('#thumbnails') do |thumbnails|
        thumbnails.should have_tag('img', :src => batch_thumbnail_path(:id => @batch.id, :image_id => 1))
        thumbnails.should have_tag('img', :src => batch_thumbnail_path(:id => @batch.id, :image_id => 2))
      end
    end
  end

  context 'without images' do
    before(:each) do
      @batch.should_receive(:lane_organised_images)
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

  context 'with events' do
    before(:each) do
      @batch.should_receive(:lane_organised_images)
      @events << 'Message 1' << 'Message 2'
      render_partial
    end

    it 'renders the events' do
      response.should have_tag('#image_events .event', :count => 2)
    end
  end
end
