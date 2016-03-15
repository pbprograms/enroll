class QuoteHousehold
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongoidSupport::AssociationProxies


  embedded_in :quote
  embeds_many :quote_members


end
