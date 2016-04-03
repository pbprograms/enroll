class QuoteHousehold
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongoidSupport::AssociationProxies


  embedded_in :quote
  embeds_many :quote_members

  field :family_id, type: String

  accepts_nested_attributes_for :quote_members

end	
