class QuoteMember
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongoidSupport::AssociationProxies

  GENDER_KINDS = %W(male female)

  EMPLOYEE_RELATIONSHIP_KINDS = %W[employee self spouse domestic_partner child_under_26  child_26_and_over disabled_child_26_and_over]
  
  # Required Fields
  # The required fields below are the minimum necessary data for plan cost calculation
  field :dob, type: Date
  field :employee_relationship, type: String

  # Optional fields
  field :first_name, type: String, default: 'Sample'
  field :middle_name, type: String
  field :last_name, type: String, default: 'Sample'
  field :name_sfx, type: String
  field :gender, type: String

  validates_presence_of :dob

  validates :gender, allow_blank: true, inclusion: { in: GENDER_KINDS, message: "must be selected" }
  validates :employee_relationship, allow_blank: false, inclusion: { in: EMPLOYEE_RELATIONSHIP_KINDS, message: "must be selected" }

  embedded_in :quote_households
  
  # age_on method returns the age of the member as of specific date (input parameter)
  def age_on(date)
    age = date.year - dob.year
    if date.month == dob.month
      age -= 1 if date.day < dob.day
    else
      age -= 1 if date.month < dob.month
    end
    age
  end
end
