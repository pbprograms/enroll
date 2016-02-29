namespace :update_shop do
  desc "Renewing employer benefit period"
  task :plan_year_renewal => :environment do 
    changed_count = 0

    # employers = {
    #   "Asia Pacific Offset, Inc" => "522041878",
    #   "The Greene Family" => "113772594"
    # }

    effective_date = Date.new(2015,4,1)
    organizations = Organization.all_employers_by_plan_year_start_on(effective_date)

    employers = organizations.map(&:employer_profile).inject({}) do |employers, profile|
      employers[profile.fein] = profile.legal_name
      employers
    end
   
    employers.each do |fein, name|
      begin
        puts "Processing employer: #{name}"
        employer = EmployerProfile.find_by_fein(fein)
        if employer.blank?
          puts "  ** employer not found"
          next
        end

        # Set ER to correct state from data migration
        # employer.employer_enrolled! if employer.binder_paid?

        # clear existing renewing plan years and benefit group assignments
        # employer.plan_years.renewing.each do |plan_year|
        #   benefit_group_ids = plan_year.benefit_groups.map(&:id)
        #   puts "Deleting renewal plan year reference from CensusEmployees"
        #   CensusEmployee.by_benefit_group_ids(benefit_group_ids).each do |census_employee|
        #     census_employee.renewal_benefit_group_assignment.destroy
        #   end
        #   plan_year.destroy
        # end

        renewal_factory = Factories::PlanYearRenewalFactory.new
        renewal_factory.employer_profile = employer
        renewal_factory.is_congress = false
        renewal_factory.renew
        changed_count += 1
      rescue => e
        puts e.to_s
      end
    end

    puts "Processed #{employers.count} employers, renewed #{changed_count} employers"
  end

  desc "Auto renew employees enrollments"
  task :family_enrollment_renewal => :environment do

    effective_date = Date.new(2015,4,1)
    organizations = Organization.all_employers_by_plan_year_start_on(effective_date)

    employers = organizations.map(&:employer_profile).inject({}) do |employers, profile|
      employers[profile.legal_name] = profile.fein
      employers
    end
    
    employer_changed_count = 0
    employers.each do |name, fein|
        employer = EmployerProfile.find_by_fein(fein)
        puts "Processing employer: #{name} -- renewing published #{employer.plan_years.renewing_published_state.any?} --census employees - #{employer.census_employees.non_terminated.size}"

        if employer.blank?
          puts "  ** employer not found"
          next
        end

        changed_count = 0
        family_missing = 0

        default_benefit_group = employer.default_benefit_group
        renewing_group = employer.renewing_plan_year.benefit_groups.first

        if default_benefit_group.blank? && employer.plan_years.published.any?
          default_benefit_group = employer.plan_years.published.first.benefit_groups.first
        end

        employer.census_employees.exists("benefit_group_assignments" => false).each do |ce|
          ce.add_benefit_group_assignment(default_benefit_group, default_benefit_group.start_on)
          ce.add_renew_benefit_group_assignment(renewing_group)
          ce.save!
        end

        employer.census_employees.non_terminated.each do |ce|
          puts "  renewing: #{ce.full_name}"
          begin
            person = Person.where(encrypted_ssn: Person.encrypt_ssn(ce.ssn)).first

            if person.blank?
              employee_role, family = Factories::EnrollmentFactory.add_employee_role({
                first_name: ce.first_name,
                last_name: ce.last_name,
                ssn: ce.ssn, 
                dob: ce.dob,
                employer_profile: employer,
                gender: ce.gender,
                hired_on: ce.hired_on
              })
              puts "created person record for #{ce.full_name}"
            else
              family = person.primary_family
            end

            if family.present?
              factory = Factories::FamilyEnrollmentRenewalFactory.new
              factory.family = family
              factory.census_employee = ce
              factory.employer = employer
              if factory.renew
                changed_count += 1
                puts "  renewed: #{ce.full_name}"
              end
            else
              puts "family missing for #{ce.full_name}"
              family_missing += 1
            end
          rescue Exception => e
            puts "Renewal failed for #{ce.full_name} due to #{e.to_s}"
          end
        end

        employer_changed_count += 1

        renewing_published_plan_year = employer.plan_years.renewing_published_state.first
        renewing_published_plan_year.advance_date! if renewing_published_plan_year && renewing_published_plan_year.may_advance_date?


      puts "Processed #{employer.census_employees.non_terminated.count} census employees, renewed #{changed_count} families, missing #{family_missing} families"
    end

    puts "Processed #{employers.count} employers, renewed #{employer_changed_count} employers"
  end
end
