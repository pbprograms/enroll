module Factories
  class EmploymentRelationshipFactory
    def initialize

    end

    def build(employee_candidate, census_employee)
      benefit_group = (census_employee.renewal_benefit_group_assignment || census_employee.active_benefit_group_assignment).benefit_group
      hired_on = census_employee.hired_on
      employer = census_employee.employer_profile
      ::Forms::EmploymentRelationship.new({
        :employer_name => employer.legal_name,
        :first_name => employee_candidate.first_name.present? ? employee_candidate.first_name.strip : nil,
        :last_name => employee_candidate.last_name.present? ? employee_candidate.last_name.strip : nil,
        :middle_name => employee_candidate.middle_name.present? ? employee_candidate.middle_name.strip : nil,
        :name_pfx => employee_candidate.name_pfx.present? ? employee_candidate.name_pfx.strip : nil,
        :name_sfx => employee_candidate.name_sfx.present? ? employee_candidate.name_sfx.strip : nil,
        :gender => employee_candidate.gender,
        :census_employee_id => census_employee.id,
        :hired_on => hired_on,
        :eligible_for_coverage_on => benefit_group.effective_on_for(hired_on)
      })
    end

    def self.build(employee_candidate, census_employee)
      factory = self.new
      Array(census_employee).map { |c_employee| factory.build(employee_candidate, c_employee) }
    end
  end
end
