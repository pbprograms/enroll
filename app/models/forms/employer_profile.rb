require 'date'
module Forms
  class EmployerProfile  < ::Forms::OrganizationSignup
    attr_reader :employer_profile

    class OrganizationAlreadyMatched < StandardError; end

    def check_existing_organization
      existing_org = Organization.where(:fein => fein).first
      if existing_org.present?
        if existing_org.employer_profile.present?
          if (Person.where({"employer_staff_roles.employer_profile_id" => existing_org.employer_profile._id}).any?)
            raise OrganizationAlreadyMatched.new
          end
        end
        return existing_org
      end
      nil
    end

    def create_employer_staff_role(current_user, employer_profile, existing_company)
      person.user = current_user
      person.employer_staff_roles << EmployerStaffRole.new(person: person, :employer_profile_id => employer_profile.id, is_owner: true, aasm_state: (existing_company ? 'is_applicant': 'is_active'))
      current_user.roles << "employer_staff" unless current_user.roles.include?("employer_staff")
      current_user.save!
      person.save!
    end

    def save(current_user, employer_profile_id)
      return false unless valid?
      begin
        match_or_create_person(current_user)
        person.save!
      rescue TooManyMatchingPeople
        errors.add(:base, "too many people match the criteria provided for your identity.  Please contact HBX.")
        return false
      rescue PersonAlreadyMatched
        errors.add(:base, "a person matching the provided personal information has already been claimed by another user.  Please contact HBX.")
        return false
      end
      if !employer_profile_id.present?
        existing_org = nil
        begin
          existing_org = check_existing_organization
        rescue OrganizationAlreadyMatched
          errors.add(:base, "a staff role for this organization has already been claimed.")
          return false
        end
        employer_profile = nil
        if existing_org
          update_organization(existing_org)
          @employer_profile = existing_org.employer_profile
        else
          org = create_new_organization
          org.save!
          @employer_profile = org.employer_profile
        end
      else
        #TODOJF TODO Change the variable name to organization id or fix the employer_profile.js
        @employer_profile = Organization.find(employer_profile_id).employer_profile
      end    
      create_employer_staff_role(current_user, @employer_profile, employer_profile_id.present?)
      true
    end

    def create_new_organization
      Organization.create!(
        :fein => fein,
        :legal_name => legal_name,
        :dba => dba,
        :employer_profile => ::EmployerProfile.new({
          :entity_kind => entity_kind
        }),
        :office_locations => office_locations
      )
    end

    def update_organization(org)
      if !org.employer_profile.present?
        org.create_employer_profile({:entity_kind => entity_kind})
        org.save!
      end
    end

  end
end
