require "rails_helper"

RSpec.describe "employers/employer_profiles/my_account/_benefits.html.erb" do
  let(:employer_profile) { FactoryGirl.build_stubbed(:employer_profile) }
  let(:plan_year) { FactoryGirl.build_stubbed(:plan_year) }
  let(:benefit_group) { FactoryGirl.build_stubbed(:benefit_group, :with_valid_dental, plan_year: plan_year ) }
  let(:plan) { FactoryGirl.build_stubbed(:plan) }
  let(:user) { FactoryGirl.create(:user) }

  before :each do
    sign_in(user)
    allow(benefit_group).to receive(:reference_plan).and_return(plan)
    allow(plan_year).to receive(:benefit_groups).and_return([benefit_group])
    allow(benefit_group).to receive(:effective_on_offset).and_return 30
    assign(:plan_years, [plan_year])
    assign(:employer_profile, employer_profile)
  end

  it "should display contribution pct by integer" do
    render "employers/employer_profiles/my_account/benefits"
    expect(rendered).to match(/Benefits - Coverage You Offer/)
    plan_year.benefit_groups.first.relationship_benefits.map(&:premium_pct).each do |pct|
      expect(rendered).to have_selector("td", text: "#{pct.to_i}%")
    end
  end

  it "should display title by effective_on_offset" do
    render "employers/employer_profiles/my_account/benefits"
    expect(rendered).to match /Date of hire following 30 days/
  end

  it "should display title by benefit groups coverage year" do
    render "employers/employer_profiles/my_account/benefits"
    expect(rendered).to match /Coverage Year/
    expect(rendered).to have_selector("p", text: "#{plan_year.start_on.to_date.to_formatted_s(:long_ordinal)} - #{plan_year.end_on.to_date.to_formatted_s(:long_ordinal)}")
  end

  it "should display 'date of hire' for 2015 renewals with date of hire effective_on_kind" do
    allow(benefit_group).to receive(:effective_on_kind).and_return 'date_of_hire'
    allow(benefit_group).to receive(:effective_on_offset).and_return 0
    render "employers/employer_profiles/my_account/benefits"
    expect(rendered).to match /date of hire/i
  end

  it "should display first of the month following or coinciding with date of hire" do
    allow(benefit_group).to receive(:effective_on_kind).and_return 'first_of_month'
    allow(benefit_group).to receive(:effective_on_offset).and_return 0
    render "employers/employer_profiles/my_account/benefits"
    expect(rendered).to match /first of the month following or coinciding with date of hire/i
  end

  it "should display 'first of month following 30 days'" do
    allow(benefit_group).to receive(:effective_on_kind).and_return 'first_of_month'
    allow(benefit_group).to receive(:effective_on_offset).and_return 30
    render "employers/employer_profiles/my_account/benefits"
    expect(rendered).to match /first of month/i
  end

  it "should display 'first of month following 60 days'" do
    allow(benefit_group).to receive(:effective_on_kind).and_return 'first_of_month'
    allow(benefit_group).to receive(:effective_on_offset).and_return 60
    render "employers/employer_profiles/my_account/benefits"
    expect(rendered).to match /first of month/i
  end

  it "should display a link to custom dental plans modal" do
    render "employers/employer_profiles/my_account/benefits"
    expect(rendered).to have_selector("a", text: "View Plans")
  end

end
