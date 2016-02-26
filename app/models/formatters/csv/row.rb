module Formatters
  module Csv
    class Row
      def initialize(file_format)
        @format = file_format
        @serialized_array = Array.new(file_format.length)
      end

      def add(a_hash)
        a_hash.each_pair do |k,v|
          @serialized_array[@format.index_for(k)] = v
        end
      end

      def to_a
        @serialized_array
      end

      def write
        @format << self
      end
    end
  end
end
