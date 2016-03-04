namespace :import do
  desc "Load new conversion employers from a file called conversion_employers.csv"
  task :load_conversion_employer_csv => :environment do
    record_count = 0
    import_count = 0
    fail_count = 0
    CSV.foreach("conversion_employers.csv", :headers => true) do |row|
      ce = Parsers::Csv::ConversionEmployer.from_row(row.fields)
      record_count = record_count + 1
      if ce.save
        import_count = import_count + 1
      else
        fail_count = fail_count + 1
        puts "=================="
        puts row.fields.inspect
        puts ce.errors.full_messages.inspect
      end
    end
    puts "Total Records: #{record_count}"
    puts "Imported Records: #{import_count}"
    puts "Failed Records: #{fail_count}"
  end
end
