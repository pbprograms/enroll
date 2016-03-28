Capybara.ignore_hidden_elements = false

module BrokerWorld
  def broker(*traits)
    attributes = traits.extract_options!
    @broker ||= FactoryGirl.create :user, *traits, attributes
  end

  def broker_agency(*traits)
    attributes = traits.extract_options!
    @broker_agency ||= FactoryGirl.create :broker , *traits, attributes
  end
end

World(BrokerWorld)

Given (/^that a broker exists$/) do
  broker_agency
  broker :with_family, :broker, organization: broker_agency
end

And(/^the broker is signed in$/) do
  login_as broker, scope: :user
end

When(/^he visits the Roster Quoting tool$/) do
  visit broker_agencies_root_path
  click_link 'Roster Quoting Tool'
end

When(/^click on the New Quote button$/) do
  click_link 'New Quote'
end

When(/^click on the Add New Employee button$/) do
  click_link "Add New Employee"
end

Then(/^a new row should be added to Employee table$/) do
  expect(page).to have_selector('table input', count: 2)
  expect(page).to have_selector('table select', count: 1)
end


When(/^click on the Upload Employee Roster button$/) do
  click_link "Upload Employee Roster"
end

When(/^the broker clicks on the Select File to Upload button$/) do
  within '.upload_csv' do
    attach_file('employee_roster_file', "#{Rails.root}/spec/test_data/employee_roster_import/Employee_Roster_sample.csv")
    find('html div#modal-wrapper div.employee-upload form.upload_csv input.btn.btn-primary.btn-br').trigger("click")
  end
end

Then(/^the broker should see the data in the table$/) do
  expect(page).to have_selector(:xpath,"//table//input[contains(@id, 'family_id')]",count: 3)
  expect(page).to have_selector(:xpath,"//table//select[contains(@id, 'relationship')]",count: 3)
end
