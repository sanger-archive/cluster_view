require 'spec_helper'

view_spec_for('batches/index') do
  it 'has a form for entering the search details' do
    response.should get_form_to(batch_search_path)
  end

  it 'has a field for entering the batch ID' do
    response.should have_text_field(:name => 'id')
  end
end
