outstanding_people = Person.where({
  "consumer_role.aasm_state" => "verifications_outstanding"
})

format = Formatters::Csv::FileFormat.new([
  :hbx_id,
  :ssn,
  :dob,
  :name_pfx,
  :first_name,
  :middle_name,
  :middle_name,
  :last_name,
  :name_sfx,
  :state_resident,
  :state_residence_determined_at,
  :lawful_presence_verified,
  :lawful_presence_authority,
  :lawful_presence_determined_at
])

format.open_file("outstanding_verifications.csv", 'w') do |csv_file|
  outstanding_people.each do |person|
    row = Formatters::Csv::Row.new(csv_file)
    row.add({
      :hbx_id => person.hbx_id,
      :ssn => person.ssn,
      :dob => person.dob,
      :name_pfx => person.name_pfx,
      :first_name => person.first_name,
      :middle_name => person.middle_name,
      :last_name => person.last_name,
      :name_sfx => person.name_sfx
    })
    residency_determined_at = person.consumer_role.residency_determined_at
    residency_date_string = residency_determined_at.blank? ? nil : residency_determined_at.strftime("%Y-%m-%dT%l:%M:%S%z")
    lp_date  = person.consumer_role.lawful_presence_determination.vlp_verified_at
    lp_date_str  = lp_date.blank? ? nil : lp_date.strftime("%Y-%m-%dT%l:%M:%S%z")
    row.add({
      :state_resident => person.consumer_role.is_state_resident,
      :state_residence_determined_at => residency_date_string,
      :lawful_presence_verified => person.consumer_role.citizenship_verified?,
      :lawful_presence_authority => person.consumer_role.lawful_presence_determination.vlp_authority,
      :lawful_presence_determined_at => lp_date_str
    })
    row.write
  end
end
