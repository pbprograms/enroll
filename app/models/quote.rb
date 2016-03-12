class Quote
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongoidSupport::AssociationProxies


  field :quote_name, type: String
  field :year, type: Integer
  field :broker_agency_profile_id, type: BSON::ObjectId

  associated_with_one :broker_agency_profile, :broker_agency_profile_id, "BrokerAgencyProfile"

  embeds_many :quote_members, cascade_callbacks: true

  def calculate_premium
    plans = Plan.limit(10).where("active_year"=>2016,"coverage_kind"=>"health")

    plans.each do |p|
      puts p.id
      puts Caches::PlanDetails.lookup_rate(p.id, TimeKeeper.date_of_record, 18)
    end

  end


end
