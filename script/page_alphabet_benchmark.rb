require 'benchmark'

@persons = Person.all
@organizations = Organization.all


Benchmark.bm do |x|
  x.report("People") { ApplicationController.new.send(:page_alphabets, @persons, 'last_name') }
  x.report("Organization") { ApplicationController.new.send(:page_alphabets, @organizations, 'legal_name') }
end
