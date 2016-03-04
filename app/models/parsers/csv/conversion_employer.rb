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

      attr_accessor  :fein,
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

      validates_presence_of :fein, :allow_blank => false
      validates_presence_of :legal_name, :allow_blank => false

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
    end
  end
end
