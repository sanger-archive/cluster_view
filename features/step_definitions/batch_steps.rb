def valid_batch_mock(batch_id)
  fake_batch = <<-END_OF_FAKE_BATCH_XML
  <?xml version="1.0" encoding="utf-8"?>
  <batch>
    <id>#{ batch_id }</id>
    <status>pending</status>
    <lanes>
      <lane position="1"><library name="sample from library 1"/></lane>
      <lane position="2"><library name="sample from library 2"/></lane>
      <lane position="3"><library name="sample from library 3"/></lane>
      <lane position="4"><library name="sample from library 4"/></lane>
      <lane position="5"><library name="sample from library 5"/></lane>
      <lane position="6"><library name="sample from library 6"/></lane>
      <lane position="7"><library name="sample from library 7"/></lane>
      <lane position="8"><library name="sample from library 8"/></lane>
    </lanes>
  </batch>
  END_OF_FAKE_BATCH_XML

  ActiveResource::HttpMock.respond_to do |mock|
    mock.get "/batches/#{batch_id}.xml", {}, fake_batch
  end
end

def invalid_batch_mock(batch_id)
  ActiveResource::HttpMock.respond_to do |mock|
    mock.get "/batches/#{batch_id}.xml", {}, nil, 404
  end
end

def pretend_batch_for(batch_id)
  batch = Object.new
  batch.instance_eval("def id ; #{ batch_id.inspect } ; end")
  batch
end

Transform /^(?:(images|thumbnails)) (\d+) to (\d+)$/ do |_,lower,upper|
  (lower.to_i..upper.to_i).map { |index| "%03i" % index }
end

Given /^batch ID "([^\"]+)" is (valid|invalid)$/ do |batch_id,validity|
  send(:"#{ validity }_batch_mock", batch_id)
end

Given /^batch "([^\"]+)" has no images$/ do |batch_id|
  Image.for_batch(pretend_batch_for(batch_id)).destroy_all
end

Given /^batch "([^\"]+)" has (images \d+ to \d+)$/ do |batch_id,filenames|
  filenames.each_with_index do |filename,index|
    Factory('Images for batch', :batch_id => batch_id, :data_file_name => filename, :position => index)
  end
end

When /^I search for batch ID "([^\"]+)"$/ do |batch_id|
  fill_in "Batch ID", :with =>batch_id
  click_button "Search"
end

When /^I view batch "([^\"]+)"$/ do |batch_id|
  When %Q{I go to the show page for batch "#{ batch_id }"}
end

When /^I attach the file "([^\"]+)" for the (left|right) image in lane ([1-8])$/ do |filename,side,lane|
  index = (lane.to_i-1) * 2
  index = index + 1 if side == 'right'
  When %Q{I attach the file "#{ filename }" to "batch[images][#{ index }][data]"}
end

Then /^I should see a thumbnail for "([^\"]+)"$/ do |filename|
  response.should have_selector(:img, :alt => filename)
end

Then /^I should see no batch thumbnails/ do
  response.should_not have_selector('#thumbnails img')
end

Then /^I should see the (left|right) thumbnail in lane ([1-8]) as "([^\"]+)"$/ do |side,lane,filename|
  response.should have_selector("#lane_#{ lane }") do |element|
    element.should have_selector('.details .lane') do |lane_details|
      lane_details.should contain(lane.to_s)
    end
    element.should have_selector(".thumbnail.#{ side } img", :alt => filename)
  end
end

Then /^I should see lanes with thumbnails:$/ do |table|
  table.hashes.each do |row|
    Then %Q{I should see the left thumbnail in lane #{ row[ 'lane' ] } as "#{ row[ 'left' ] }"}
    Then %Q{I should see the right thumbnail in lane #{ row[ 'lane' ] } as "#{ row[ 'right' ] }"}
  end
end
