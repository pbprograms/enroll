module Forms
  module PeopleNames
    def self.included(base)
      base.class_eval do
        attr_reader :first_name, :middle_name, :last_name
        attr_reader :name_pfx, :name_sfx

        def first_name=(val)
          @first_name = val.blank? ? nil : val.strip
        end

        def middle_name=(val)
          @middle_name = val.blank? ? nil : val.strip
        end

        def last_name=(val)
          @last_name = val.blank? ? nil : val.strip
        end

        def name_pfx=(val)
          @name_pfx =  val.blank? ? nil : val.strip
        end

        def name_sfx=(val)
          @name_sfx =  val.blank? ? nil : val.strip
        end
      end
    end
  end
end