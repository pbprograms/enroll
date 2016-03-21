module GAWorld
  def general_agency(*traits)
    attributes = traits.extract_options!
    @general_agency ||= FactoryGirl.create :general_agency, *traits, attributes.merge(:general_agency_traits => :with_staff)
  end

  def user(*traits)
    attributes = traits.extract_options!
    @user ||= FactoryGirl.create :user, *traits, attributes
  end
end
World(GAWorld)

Given /^a general agency agent visits the DCHBX$/ do
  visit '/'
end

When /^they click the 'New General Agency' button$/ do
  click_link 'General Agency Registration'
end

Then /^they should see the new general agency form$/ do
  expect(page).to have_content('New General Agency')
end

When /^they complete the new general agency form and hit the 'Submit' button$/ do
  fill_in 'organization[first_name]', with: Forgery(:name).first_name
  fill_in 'organization[last_name]', with: Forgery(:name).last_name
  fill_in 'jq_datepicker_ignore_organization[dob]', with: (Time.now - rand(20..50).years).strftime('%m/%d/%Y')
  find('.interaction-field-control-organization-email').click
  fill_in 'organization[email]', with: Forgery(:email).address
  fill_in 'organization[npn]', with: '2222222222'

  fill_in 'organization[legal_name]', with: (company_name = Forgery(:name).company_name)
  fill_in 'organization[dba]', with: company_name
  fill_in 'organization[fein]', with: '333333333'

  find(:xpath, "//p[contains(., 'Select Entity Kind')]").click
  find(:xpath, "//li[contains(., 'S Corporation')]").click

  find(:xpath, "//p[contains(., 'Select Practice Area')]").click
  find(:xpath, "//li[contains(., 'Both – Individual & Family AND Small Business Marketplaces')]").click

  find(:xpath, "//div[@class='language_multi_select']//p[@class='label']").click
  find(:xpath, "//li[contains(., 'English')]").click

  fill_in 'organization[office_locations_attributes][0][address_attributes][address_1]', with: Forgery(:address).street_address
  fill_in 'organization[office_locations_attributes][0][address_attributes][city]', with: 'Washington'

  find(:xpath, "//p[contains(., 'SELECT STATE')]").click
  find(:xpath, "//li[contains(., 'DC')]").click

  fill_in 'organization[office_locations_attributes][0][address_attributes][zip]', with: '20001'

  fill_in 'organization[office_locations_attributes][0][phone_attributes][area_code]', with: Forgery(:address).phone.match(/\((\d\d\d)\)/)[1]
  fill_in 'organization[office_locations_attributes][0][phone_attributes][number]', with: Forgery(:address).phone.match(/\)(.*)$/)[1]

  find('.interaction-click-control-create-general-agency').click
end

Then /^they should see a confirmation message$/ do
  expect(page).to have_content('Your registration has been submitted. A response will be sent to the email address you provided once your application is reviewed.')
end

Then /^a pending approval status$/ do
  expect(GeneralAgencyProfile.last.aasm_state).to eq('is_applicant')
end

Given /^an HBX admin exists$/ do
  user :with_family, :hbx_staff
end

Given /^a general agency, pending approval, exists$/ do
  general_agency
end

When /^the HBX admin visits the general agency list$/ do
  login_as user, scope: :user
  visit exchanges_hbx_profiles_root_path
  click_link 'General Agencies'
end

Then /^they should see the pending general agency$/ do
  expect(page).to have_content(general_agency.legal_name)
end

When /^they approve the general agency$/ do
  click_link general_agency.legal_name
  click_link 'Staff'
  click_link 'Staff'
  click_link 'Staff'
  click_link 'Staff'
  sleep 5
  click_link general_agency.general_agency_profile.general_agency_staff_roles.first.full_name
  click_button 'Approve'
end

Then /^they should see updated status$/ do
  expect(find('.alert')).to have_content('Staff approved successfully.')
end

Then /^the general agency should receive an email$/ do
  pending "figuring out whether open_email isn't working or the email isn't being sent"
  open_email(general_agency.general_agency_profile.general_agency_staff_roles.first.emails.first.address)
end

Given /^a general agency, approved, awaiting account creation, exists$/ do
  pending # Write code here that turns the phrase above into concrete actions
end

When /^the HBX admin visits the link received in the approval email$/ do
  pending # Write code here that turns the phrase above into concrete actions
end

Then /^they should see an account creation form$/ do
  pending # Write code here that turns the phrase above into concrete actions
end

When /^they complete the account creation form and hit the 'Submit' button$/ do
  pending # Write code here that turns the phrase above into concrete actions
end

Then /^they see the General Agency homepage$/ do
  pending # Write code here that turns the phrase above into concrete actions
end
