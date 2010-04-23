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

Given /^batch ID "([^\"]+)" is (valid|invalid)$/ do |batch_id,validity|
  send(:"#{ validity }_batch_mock", batch_id)
end

When /^I search for batch ID "([^\"]*)"$/ do |batch_id|
  fill_in "Batch ID", :with =>batch_id
  click_button "Search"
end

Then /^I should see a thumbnail for "([^\"]*)"$/ do |arg1|
  response.should have_selector(:img, :alt => arg1)
end
