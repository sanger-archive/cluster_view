module BatchesHelper
  def link_to_full_size_image(image, &block)
    link_to(batch_image_path(:id => image.batch_id, :image_id => image.id), &block)
  end

  def status_of(batch)
    translate("batches.statuses.#{ batch.status.downcase.underscore }")
  end
  
  # Returns a the order number of an image based on it's position.
  def image_number(side, lane)
    case side
      when :left 
        image_number = 8 + lane
      when :right
        image_number = 9 - lane
      end
  end
  
end
