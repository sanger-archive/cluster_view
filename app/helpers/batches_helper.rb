module BatchesHelper
  def link_to_full_size_image(image, &block)
    link_to(batch_image_path(:id => image.batch_id, :image_id => image.id), &block)
  end

  def status_of(batch)
    translate("batches.statuses.#{ batch.status.downcase.underscore }")
  end
end
