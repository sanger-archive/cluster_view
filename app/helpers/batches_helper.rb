module BatchesHelper
  def thumbnail_for(sample, image, side)
    render(
      :partial => 'batches/thumbnail',
      :locals => { :sample => sample, :image => image, :side => side }
    )
  end

  def link_to_full_size_image(image, &block)
    link_to(batch_image_path(:id => image.batch_id, :image_id => image.id), &block)
  end

  def status_of(batch)
    translate("batches.statuses.#{ batch.status.downcase.underscore }")
  end

  def labeled_check_box_tag(name, label, value = 'yes')
    check_box_tag(name, value) << label_tag(name, label)
  end

  def image_upload_tag(side, sample, image)
    root_name = "batch[images][#{ sample.image_index_for_side(side) }]"
    
    content = []
    content << file_field_tag("#{ root_name }[data]")
    unless image.nil?
      content << labeled_check_box_tag("#{ root_name }[delete]", "Delete image #{ image.root_filename }") 
      content << hidden_field_tag("#{ root_name }[id]", image.id)
    end
    content.join("\n")
  end
end
