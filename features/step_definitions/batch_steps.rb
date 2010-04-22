def valid_batch_mock(batch_id)
  fake_batch = {:id => batch_id}.to_xml(:root => "batch")
  ActiveResource::HttpMock.respond_to do |mock|
    mock.get "/batches/#{batch_id}.xml", {}, fake_batch
  end
end

def invalid_batch_mock(batch_id)
  ActiveResource::HttpMock.respond_to do |mock|
    mock.get "/batches/#{batch_id}.xml", {}, nil, 404
  end
end


When /^I search for a valid batch ID of "([^\"]*)"$/ do |batch_id|
  valid_batch_mock(batch_id)
  fill_in "Batch ID", :with =>batch_id
  click_button "Search"
end

When /^I search for an invalid batch ID of "([^\"]*)"$/ do |batch_id|
  invalid_batch_mock(batch_id)
  fill_in "Batch ID", :with => batch_id
  click_button "Search"
end