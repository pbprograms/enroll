module Parsers
  module Csv
    class ConversionEmployer
      include ActiveModel::Validations
      include ActiveModel::Model

      ROW_MAPPING = [
        :fein,
        :dba,
        :legal_name,
        :primary_location_address_1,
        :primary_location_address_2,
        :primary_location_city,
        :primary_location_state,
        :primary_location_zip,
        :mailing_location_address_1,
        :mailing_location_address_2,
        :mailing_location_city,
        :mailing_location_state,
        :mailing_location_zip,
        :ignore,
        :ignore,
        :contact_email,
        :contact_phone,
        :enrolled_employee_count,
        :new_hire_count,
        :ignore,
        :ignore,
        :ignore,
        :ignore,
        :ignore,
        :broker_name,
        :broker_npn
      ]

      attr_accessor :fein,
        :dba,
        :legal_name,
        :primary_location_address_1,
        :primary_location_address_2,
        :primary_location_city,
        :primary_location_state,
        :primary_location_zip,
        :mailing_location_address_1,
        :mailing_location_address_2,
        :mailing_location_city,
        :mailing_location_state,
        :mailing_location_zip,
        :contact_email,
        :contact_phone,
        :enrolled_employee_count,
        :new_hire_count,
        :broker_name,
        :broker_npn

      validates_presence_of :legal_name, :allow_blank => false
      validates_length_of :fein, is: 9

      validate :validate_new_fein
      validate :broker_exists_if_specified

      def self.from_row(row)
        return ConversionEmployer.new if row.nil?
        record_attrs = {}
        ROW_MAPPING.each_with_index do |k, idx|
          value = row[idx]
          unless (k == :ignore) || value.blank?
            record_attrs[k] = row[idx]
          end
        end
        ConversionEmployer.new(record_attrs)
      end

      def validate_new_fein
        return true if fein.blank?
        if Organization.where(:fein => fein).any?
          errors.add(:fein, "is already taken")
        end
      end

      def broker_exists_if_specified
        return true if broker_npn.blank?
        unless BrokerRole.by_npn(broker_npn).any?
          errors.add(:broker_npn, "invalid broker NPN")
        end
      end

      def map_office_locations
        locations = []
        main_address = Address.new(
          :kind => "work",
          :address_1 => primary_location_address_1,
          :address_2 => primary_location_address_2,
          :city =>  primary_location_city,
          :state => primary_location_state,
          :zip => primary_location_zip
        )
        mailing_address = Address.new(
          :kind => "work",
          :address_1 => mailing_location_address_1,
          :address_2 => mailing_location_address_2,
          :city =>  mailing_location_city,
          :state => mailing_location_state,
          :zip => mailing_location_zip
        )
        main_location = OfficeLocation.new({
          :address => main_address,
          :phone => Phone.new({
             :kind => "work",
             :full_phone_number => contact_phone
          }),
          :is_primary => true 
        })
        locations << main_location
        if !mailing_address.blank?
           if !mailing_address.matches?(main_address)
              locations << OfficeLocation.new({
                :is_primary => false,
                :address => mailing_address
              })
           end
        end
        locations
      end

      def save
        return false unless valid?
        new_organization = Organization.new({
           :fein => fein,
           :legal_name => legal_name,
           :dba => dba,
           :office_locations => map_office_locations,
           :employer_profile => EmployerProfile.new({
              :entity_kind => "c_corporation"
           })
        })
        save_result = new_organization.save
        propagate_errors(new_organization)
        return save_result
      end

      def propagate_errors(org)
        org.errors.each do |attr, err|
          errors.add(attr, err)
        end
        org.office_locations.each_with_index do |office_location, idx|
          office_location.errors.each do |attr, err|
            errors.add("office_location_#{idx}_" + attr.to_s, err)
          end
        end
      end
    end
  end
end
