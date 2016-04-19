require 'rails_helper'

RSpec.describe CensusEmployeeImport, :type => :model do

  let(:tempfile) { double("", path: 'spec/test_data/census_employee_import/DCHL Employee Census.xlsx') }
  let(:file) {
    double("", :tempfile => tempfile)
  }
  let(:employer_profile) { FactoryGirl.create(:employer_profile) }
  let(:sheet) {
    Roo::Spreadsheet.open(file.tempfile.path).sheet(0)
  }
  let(:subject) {
    CensusEmployeeImport.new({file: file, employer_profile: employer_profile})
  }

  context "initialize without employer_role and file" do
    it "throws exception" do
      expect { CensusEmployeeImport.new() }.to raise_error(ArgumentError)
    end
  end

  context "initialize with employer_role and file" do
    it "should not throw an exception" do
      expect { CensusEmployeeImport.new({file: file, employer_profile: employer_profile}) }.to_not raise_error
    end
  end

  it "should validate headers" do
    sheet_header_row = sheet.row(1)
    column_header_row = sheet.row(2)
    expect(subject.header_valid?(sheet_header_row) && subject.column_header_valid?(column_header_row)).to be_truthy
  end

  context "One employee with one dependent" do
    it "should added a employee with a dependent" do
      expect(subject.save).to be_truthy
      expect(subject.load_imported_census_employees.count).to eq(2) # 1 employee + 1 dependent
      expect(subject.load_imported_census_employees.first).to be_a CensusEmployee
      expect(subject.load_imported_census_employees.first.census_dependents.count).to eq(1)
      expect(subject.load_imported_census_employees.last).to be_a CensusDependent
    end

    it "should save the employee with address" do
      expect(subject.save).to be_truthy
      expect(subject.load_imported_census_employees.first.address.present?).to be_truthy
    end
  end

  context "relationship field is empty" do

    let(:tempfile) { double("", path: 'spec/test_data/census_employee_import/DCHL Employee Census 2.xlsx') }
    let(:file) {
      double("", :tempfile => tempfile)
    }
    let(:employer_profile) { FactoryGirl.create(:employer_profile) }
    let(:sheet) {
      Roo::Spreadsheet.open(file.tempfile.path).sheet(0)
    }
    let(:subject) {
      CensusEmployeeImport.new({file: file, employer_profile: employer_profile})
    }

    it "should not add the 2nd employee/dependent (as relationship is missing)" do
      expect(subject.save).to be_falsey
      expect(subject.load_imported_census_employees.count).to eq(1) # 1 employee + no dependents
      expect(subject.load_imported_census_employees.first).to be_a CensusEmployee
      expect(subject.load_imported_census_employees.first.census_dependents.count).to eq(0)
    end

    it "should not save successfully" do
      expect(subject.save).to be_falsey
    end
  end
end
