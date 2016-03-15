require 'benchmark'

@persons = Person.all
@organizations = Organization.all


Benchmark.bm do |x|
  x.report("People") { 100.times { ApplicationController.new.send(:page_alphabets, @persons, 'last_name') } }
  x.report("Organization") { 100.times { ApplicationController.new.send(:page_alphabets, @organizations, 'legal_name') } }
end
