When /^I search for batch number "([^\"]*)"$/ do |batch_number|
  fill_in "Batch ID", :with => batch_number
  click_button "Search"
end

Then /^I see the batch page for batch "([^\"]*)"$/ do |batch_number|
  response.should contain("Batch Number #{batch_number}")
end

When /^I search for a non\-existent batch number "([^\"]*)"$/ do |batch_number|
  lambda {Batch.find(batch_number)}.
    should raise_error(ActiveResource::ResourceNotFound)

  fill_in "Batch ID", :with => batch_number
  click_button "Search"
end
