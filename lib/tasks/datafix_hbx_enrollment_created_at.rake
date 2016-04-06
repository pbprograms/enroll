
namespace :datafix do
  desc "Datafix : updates all existing records where created_at is nil with current timestamp"
  task hbx_enrollment_created_at_nil: :environment do
  	enrollments_with_create_at_nil = HbxEnrollment.where(:created_at.exists => false)
  	puts "Found #{enrollments_with_create_at_nil} records with created_at nil ."
  	enrollments_with_create_at_nil.each do |enrollment|
  		enrollment.set(:created_at => TimeKeeper.datetime_of_record)
  	end
  end
end