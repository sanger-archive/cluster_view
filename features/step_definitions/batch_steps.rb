When /^I search for a batch ID of "([^\"]*)"$/ do |batch_id|
  When %Q{I fill in "Batch ID" with "#{ batch_id }"}
  When 'I press "Search"'
end

Given /^there is no batch with an ID of "([^\"]*)"$/ do |batch_id|
  lambda {Batch.find(batch_id)}.
    should raise_error(ActiveResource::ResourceNotFound)
end