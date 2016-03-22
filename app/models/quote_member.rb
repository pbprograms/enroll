class QuoteMember
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongoidSupport::AssociationProxies

  GENDER_KINDS = %W(male female)

  EMPLOYEE_RELATIONSHIP_KINDS = %W[self spouse domestic_partner child_under_26  child_26_and_over disabled_child_26_and_over]

  field :first_name, type: String
  field :middle_name, type: String
  field :last_name, type: String
  field :name_sfx, type: String

  field :dob, type: Date

  field :gender, type: String

  field :employee_relationship, type: String

  validates_presence_of :first_name, :dob, :employee_relationship

  #validates :gender,    allow_blank: false,    inclusion: { in: GENDER_KINDS, message: "must be selected" }

  embedded_in :quote_households

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
