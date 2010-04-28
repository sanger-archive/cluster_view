module BatchesHelper
  def lane_organised_images_for(batch, &block)
    images = batch.images.inject([ nil ] * 16) { |images,image| images[ image.position ] = image ; images }
    batch.samples.zip(images.in_groups_of(2)).each do |sample,(left,right)|
      yield(sample, left, right)
    end
  end

  def thumbnail_for(sample, image, side)
    render(
      :partial => 'batches/thumbnail',
      :locals => { :sample => sample, :image => image, :side => side }
    )
  end

  def link_to_full_size_image(image)
    link_to(h(image.filename), batch_image_path(:id => image.batch_id, :image_id => image.id))
  end

  def status_of(batch)
    translate("batches.statuses.#{ batch.status.downcase.underscore }")
  end

  def image_upload_tag(root_name, side, sample, image)
    index = (sample.lane-1) * 2
    index = index + 1 if side == :right

    root_name << "[#{ index }]"
    
    content = ''
    content << hidden_field_tag("#{ root_name }[id]", image.id) << "\n" unless image.nil?
    content << file_field_tag("#{ root_name }[data]")
    content
  end
end
