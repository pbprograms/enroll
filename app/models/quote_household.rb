class QuoteHousehold
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongoidSupport::AssociationProxies

  field :family_id, type: String

  embedded_in :quote
  embeds_many :quote_members

  accepts_nested_attributes_for :quote_members

end
