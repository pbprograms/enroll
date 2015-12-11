namespace :seed do
  desc "Load the brokers.json file"
  task :broker_json => :environment do
    b_json_file = File.open("db/seedfiles/brokers.json")
    b_json = JSON.load(b_json_file.read)
    b_json.each do |b_rec|
      rec = b_rec.dup
      broker_attrs = rec.delete("broker_role_attributes")
      new_person = Person.new(rec)
      new_person.deep_merge!({
        first_name: new_person.first_name.try(:strip),
        last_name: new_person.last_name.try(:strip),
        middle_name: new_person.middle_name.try(:strip),
        name_sfx: new_person.name_sfx.try(:strip),
        name_pfx: new_person.name_pfx.try(:strip)
        })
      new_person.broker_role = BrokerRole.new(broker_attrs)
      begin
      new_person.save!
      rescue
        raise b_rec.inspect
      end
    end
  end
end
