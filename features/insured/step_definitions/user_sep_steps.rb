module UserSepWorld
  def user(*traits)
    attributes = traits.extract_options!
    @user ||= FactoryGirl.create :user, *traits, attributes
  end
end

World(UserSepWorld)

Given(/^a user exists$/) do
  user :consumer, :with_family, :ridp_verified
  @browser.goto("http://localhost:3000/users/sign_in")
end

Given(/^the user signs in$/) do
  @browser.element(text: /Sign In/i).wait_until_present
  @browser.text_field(class: /interaction-field-control-user-email/).set(user.email)
  @browser.text_field(class: /interaction-field-control-user-password/).set(user.password)
  @browser.element(class: /interaction-click-control-sign-in/).click
end

Given(/^has already enrolled for SEP$/) do
  FactoryGirl.create :hbx_profile
  user.person.consumer_role = FactoryGirl.build(:consumer_role, person: user.person, aasm_state: 'fully_verified')
  user.person.save
  user.primary_family.special_enrollment_periods.push FactoryGirl.build(:special_enrollment_period, qle_on: Date.yesterday, effective_on_kind: ['first_of_month'])
  user.primary_family.save
end

When(/^the user goes to the families homepage$/) do
  @browser.goto("http://localhost:3000/families/home?tab=home")
end

When(/^the user clicks Shop for plans button$/) do
  @browser.element(class: /interaction-click-control-shop-for-plans/).wait_until_present
  scroll_then_click(@browser.element(class: /interaction-click-control-shop-for-plans/))
end

Then(/^the user should be able to use their existing SEP$/) do
  sleep 1
  expect(@browser.a(text: /Shop with existing SEP/i).visible?).to be_truthy
end
