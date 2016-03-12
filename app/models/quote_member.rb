class QuoteMember
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongoidSupport::AssociationProxies


  field :name, type: String
  field :age, type: Integer

  embedded_in :quote


end
