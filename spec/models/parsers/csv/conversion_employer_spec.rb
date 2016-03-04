require "rails_helper"

describe Parsers::Csv::ConversionEmployer, "given a blank row" do
  let(:raw_row) { "" }
  let(:row) { CSV.parse_line(raw_row) }

  subject { ::Parsers::Csv::ConversionEmployer.from_row(row) }

  it "is invalid" do
    expect(subject.valid?).to be_falsey
  end

end

RSpec.shared_examples "a parsed ConversionEmployer row entry" do |expected_properties|
  expected_properties.each_pair do |k, v|
    it "has the parsed the correct value for #{k}" do
      expect(subject.send(k.to_sym)).to eql(v)
     end
  end
end

describe Parsers::Csv::ConversionEmployer, "given a non-blank row" do
  let(:row) { CSV.parse_line(raw_row) }

  subject { ::Parsers::Csv::ConversionEmployer.from_row(row) }

  describe "containing only an fein" do
    let(:raw_row) { "012345678" }

    it "is invalid" do
      expect(subject.valid?).to be_falsey
    end

  end

  describe "given a full, valid row" do
    let(:raw_row) { "521780000,\"Care Pharmacy DBA\",\"Care Pharmacy\",\"3001 P Street N.W.\",\" \",\"Washington\",\"DC\",20007,\"3001 P Street N.W. 2\",\"Suite WHATEVER\",\"Seattle\",\"WA\",\"55532\",\"Bug\",\"Dance\",\"care@carerx.com\",\"2020374000\",\"3\",\" \",\"3001 P Street N.W.\",\" \",\"Washington\",\"DC\",\"20007\",\"Debby C Mcac\",\"777660\",\" \",\" \",\"07/01/2016\",\"CareFirst BlueCross BlueShield\",\"Single Plan from Carrier \",\"BC HMO Ref  500 Gold Trad Dental Drug\",\"86052DC0480005-01\",\"BC HMO Ref  500 Gold Trad Dental Drug\",\"86052DC0480005-01\"," }

    it "is valid" do
      expect(subject.valid?).to be_truthy
    end

    EXPECTED_PROPERTIES = {
      :fein => "521780000",
      :dba => "Care Pharmacy DBA",
      :legal_name => "Care Pharmacy",
      :primary_location_address_1 => "3001 P Street N.W.",
      :primary_location_address_2 => nil,
      :primary_location_city => "Washington",
      :primary_location_state => "DC",
      :primary_location_zip => "20007",
      :mailing_location_address_1 => "3001 P Street N.W. 2",
      :mailing_location_address_2 => "Suite WHATEVER",
      :mailing_location_city => "Seattle",
      :mailing_location_state => "WA",
      :mailing_location_zip => "55532",
      :contact_email => "care@carerx.com",
      :contact_phone => "2020374000",
      :enrolled_employee_count => "3",
      :new_hire_count => nil
    }

    it_should_behave_like "a parsed ConversionEmployer row entry", EXPECTED_PROPERTIES
  end
end
