namespace :import do
  desc "Load new conversion employers from a file called conversion_employers.csv"
  task :load_conversion_employer_csv => :environment do
    CSV.foreach("conversion_employers.csv", :headers => true) do |row|
      ce = Parsers::Csv::ConversionEmployer.from_row(row.fields)
      unless ce.save
        puts "=================="
        puts row.fields.inspect
        puts ce.errors.full_messages.inspect
      end
    end
  end
end
