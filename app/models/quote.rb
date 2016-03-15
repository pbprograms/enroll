class Quote
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongoidSupport::AssociationProxies

  PERSONAL_RELATIONSHIP_KINDS = [
    :employee,
    :spouse,
    :domestic_partner,
    :child_under_26,
    :child_26_and_over
  ]

  field :quote_name, type: String
  field :year, type: Integer
  field :broker_agency_profile_id, type: BSON::ObjectId

  field :reference_plan_id, type: BSON::ObjectId

  associated_with_one :broker_agency_profile, :broker_agency_profile_id, "BrokerAgencyProfile"

  embeds_many :quote_households

  embeds_many :relationship_benefits, cascade_callbacks: true

  def calculate_premium
    plans = Plan.limit(10).where("active_year"=>2016,"coverage_kind"=>"health")

    plans.each do |p|
      puts p.id
      puts Caches::PlanDetails.lookup_rate(p.id, TimeKeeper.date_of_record, 18)
    end

  end

  def gen_data

    build_relationship_benefits

    qh = self.quote_households.build

    qm = qh.quote_members.build

    qm.name = "Tony"
    qm.age = 35

    qm = qh.quote_members.build

    qm.name = "Gabriel"
    qm.age = 4

    self.save

  end

  def build_relationship_benefits
    self.relationship_benefits = PERSONAL_RELATIONSHIP_KINDS.map do |relationship|
       self.relationship_benefits.build(relationship: relationship, offered: true)
    end
  end


end
