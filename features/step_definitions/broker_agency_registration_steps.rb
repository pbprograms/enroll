When(/^Broker visits the HBX Broker Registration page$/) do
  visit '/'
  find(".interaction-click-control-broker-registration").click
end

When(/^Broker clicks on Broker Registration tab$/) do
  find(".interaction-click-control-broker-registration").click
end

Then(/^the Broker should see New Broker Agency as the active tab$/) do 
  expect(page).to have_content("Broker Agency Information")
	expect(find(:xpath, "//input[@id='new_broker_agency']/..")[:class]).to eq "btn btn-default active"
end