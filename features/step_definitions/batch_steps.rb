When /^I search for a batch number of "([^\"]*)"$/ do |batch_number|
  fill_in "Batch Number", :with => batch_number
  click_button "Search"
end

Given /^there is no batch with a number of "([^\"]*)"$/ do |batch_number|
  lambda {Batch.find(batch_number)}.
    should raise_error(ActiveResource::ResourceNotFound)
end