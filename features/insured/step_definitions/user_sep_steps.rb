module UserSepWorld
  def user(*traits)
    attributes = traits.extract_options!
    @user ||= FactoryGirl.create :user, *traits, attributes
  end
end

World(UserSepWorld)

Given(/^a user exists$/) do
  user :consumer, :with_family
  @browser.goto("http://localhost:3000/users/sign_in")
  puts @user.password
end

Given(/^the user signs in$/) do
  @browser.element(text: /Sign In/i).wait_until_present
  @browser.text_field(class: /interaction-field-control-user-email/).set(@user.email)
  @browser.text_field(class: /interaction-field-control-user-password/).set(@user.password)
  @browser.element(class: /interaction-click-control-sign-in/).click
end

Given(/^has already enrolled for SEP$/) do
  @user.primary_family.special_enrollment_periods.push FactoryGirl.build(:special_enrollment_period)      
end

When(/^the user goes to the families homepage$/) do
  @browser.goto("http://localhost:3000/families/home?tab=home")
  @browser.element(class: /interaction-click-control-shop-for-plans/).wait_until_present
 scroll_then_click(@browser.element(class: /interaction-click-control-shop-for-plans/))
end

When(/^the user clicks Shop for plans button$/) do
  sleep 30
  @browser.element(class: /interaction-click-control-shop-for-plans/).click
end

Then(/^SEP popup should not appear$/) do
  sleep 5
  expect(@browser.div(class: "seps-panel").visible?).to be_false
end