module Formatters
  module Csv
    class FileFormat
      class NoSuchHeaderError < StandardError; end
      class FileNotOpenError < StandardError; end

      attr_reader :length

      def initialize(header_list = [])
        @header_indexes = {}
        @headers = header_list.map(&:to_s)
        header_list.each_with_index do |h, index|
          @header_indexes[h.to_s] = index
        end
        @length = header_list.length
      end

      def index_for(key)
        raise NoSuchHeaderError.new(key) unless @header_indexes.has_key?(key.to_s) 
        @header_indexes[key.to_s]
      end

      def open_file(path, mode)
        CSV.open(path, mode) do |csv|
          @csv_file = csv
          csv << @headers
          yield self
          @csv_file = nil
        end
      end

      def <<(row)
        raise FileNotOpenError.new if @csv_file.nil?
        appended_row = row.respond_to?(:to_a) ? row.to_a : row
        @csv_file << appended_row
      end
    end
  end
end
