def configure_valid_batch_for(active_resource, batch_id)
  active_resource.get "/batches/#{ batch_id }.xml", {}, <<-END_OF_FAKE_BATCH_XML
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
end

def configure_invalid_batch_for(active_resource, batch_id)
  active_resource.get "/batches/#{ batch_id }.xml", {}, nil, 404
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
  @batch_setup_functions.push(lambda do |mock|
    send(:"configure_#{ validity }_batch_for", mock, batch_id)
  end)
end

Given /^the batches are:$/ do |batch_table|
  @batch_setup_functions.push(lambda do |mock|
    batch_table.hashes.each do |row|
      send(:"configure_#{ row['state'] }_batch_for", mock, row['id'])
    end
  end)
end

Then /^setup the batches$/ do
  ActiveResource::HttpMock.respond_to do |mock|
    @batch_setup_functions.each { |function| function.call(mock) }
  end
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
  fill_in_and_submit('id', :with => batch_id)
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

Then /^I should not see a (left|right) thumbnail in lane (\d+)$/ do |side,lane|
  response.should_not have_selector("#lane_#{ lane } .thumbnail.#{ side } img")
end

Then /^I should see lanes with thumbnails:$/ do |table|
  table.hashes.each do |row|
    Then %Q{I should see the left thumbnail in lane #{ row[ 'lane' ] } as "#{ row[ 'left' ] }"}
    Then %Q{I should see the right thumbnail in lane #{ row[ 'lane' ] } as "#{ row[ 'right' ] }"}
  end
end

Given /^batch "([^\"]+)" has image "([^\"]+)" for the (left|right) image in lane (\d+)$/ do |batch_id,filename,side,lane|
  index = (lane.to_i-1) * 2
  index = index + 1 if side == 'right'
  Factory('Images for batch', :batch_id => batch_id, :data_file_name => File.basename(filename), :position => index)
end

Then /^I should not see an option "([^\"]+)"$/ do |label|
  response.should_not have_selector('label', :text => label)
end

Then /^the "Delete image 2617" checkbox should not be checked foo$/ do
  response.should have_selector('#lane_3') do |lane|
    raise lane.to_s.inspect
  end
end

Given /^the samples for batches are:$/ do |table|
  @batch_setup_functions.push(lambda do |http|
    table.hashes.inject(Hash.new { |h,k| h[ k ] = [] }) do |batches,row|
      batches[ row['batch'] ][ row['lane'].to_i ] = row['sample']
      batches
    end.each do |batch_id,lanes|
      batch_xml = ''
      xml = Builder::XmlMarkup.new(:target => batch_xml)
      xml.batch {
        xml.tag!(:id, batch_id)
        xml.lanes {
          lanes.each_with_index do |sample,index|
            next if sample.nil?
            xml.lane(:position => index) { 
              xml.library(:name => sample)
            }
          end
        }
      }
      http.get "/batches/#{ batch_id }.xml", {}, batch_xml
    end
  end)
end

When /^I choose to compare lane "([^\"]+)" of batch "([^\"]+)" with lane "([^\"]+)" of batch "([^\"]+)"$/ do |left_lane,left_id,right_lane,right_id|
  When %Q{I fill in "Left batch" with "#{ left_id }"}
  When %Q{I select "#{ left_lane }" from "Left lane"}
  When %Q{I fill in "Right batch" with "#{ right_id }"}
  When %Q{I select "#{ right_lane }" from "Right lane"}
  When %Q{I press "Compare"}
end

Then /^show me what I'm looking at$/ do
  $stderr.puts response.body
  raise 'foo'
end
