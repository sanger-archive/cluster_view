module BulkUploadHelper
  def bulk_upload_container(selector, batch = nil, &block)
    content = content_tag(:div, block_given? ? capture(&block) : '', :id => 'bulk_upload')
    content << content_tag(:script, "$('#{ selector }').click(function(){$('#bulk_upload').load('#{ bulk_start_path(:id => batch) }');});")
    block_given? ? concat(content) : content
  end

  def field_for_batch_id(batch)
    field_options = { }
    field_options.update(:disabled => 'disabled') unless batch.nil?
    content_tag(
      :li, 
      content_tag(:label, 'Batch ID:', :for => 'batch_id') <<
      text_field_tag('batch_id', batch.try(:id), field_options),
      :class => 'string required'
    )
  end
end
