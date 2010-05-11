require 'spec_helper'

describe 'batches/_thumbnail' do
  before(:each) do
    @batch = mock(Batch, :id => 5678)
    @sample = Batch::Sample.new(@batch, 3, 'sample')
  end

  def render_view(locals)
    render(
      :partial => 'batches/thumbnail', 
      :locals => {
        :sample => @sample,
        :body => 'BODY',
        :form => Formtastic::SemanticFormBuilder.new(:batch, nil, @response.template, {}, nil)
      }.merge(locals)
    )
  end

  context 'with an image' do
    before(:each) do
      @sample.stub!(:image).with(:left).and_yield(
        mock_model(Image, :id => 1234, :batch_id => @batch.id, :data_file_name => 'dir/filename', :root_filename => 'filename')
      )
      render_view(:side => :left)
    end

    it 'has a root level element of the right class' do
      response.should have_tag('.thumbnail.left')
    end

    it 'displays a thumbnail' do
      response.should have_tag(:img, :src => batch_thumbnail_path(:id => @batch.id, :image_id => 1234), :alt => 'dir/filename')
    end

    it 'displays a link to the full image' do
      response.should have_link_to(batch_image_path(:id => @batch.id, :image_id => 1234))
    end

    it 'displays a file upload field' do
      response.should have_file_field(:name => 'batch[images][4][data]')
    end
  end

  context 'without an image' do
    before(:each) do
      @sample.stub!(:image).with(:right)
      render_view(:side => :right)
    end

    it 'does not display a thumbnail' do
      response.should_not have_tag(:img, :src => batch_thumbnail_path(:id => @batch.id, :image_id => 1234), :alt => 'filename foo')
    end

    it 'does not display a link to the full image' do
      response.should_not have_link_to(batch_image_path(:id => @batch.id, :image_id => 1234))
    end

    it 'displays a file upload field' do
      response.should have_file_field(:name => 'batch[images][5][data]')
    end
  end
end
