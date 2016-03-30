class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  PRIORITY_KINDS = %w[low normal high]

  field :title, type: String
  field :body, type: String
  field :priority, type: String, default: "normal"

  belongs_to :user

  # Enable polymorphic associations
  embedded_in :commentable, polymorphic: true

  validates_presence_of   :user
  validates_presence_of   :body
  validates_presence_of   :priority, message: "Choose a priority"
  validates_inclusion_of  :priority, in: PRIORITY_KINDS, message: "%{value} is not a valid priority kind"

  scope :in_order,  -> { order('created_at ASC') }
  scope :recent,    -> { reorder('created_at DESC') }

  def priority=(new_priority)
    write_attribute(:priority, new_priority.to_s.downcase)
  end

  def is_high_priority?
    priority == "high"
  end

  def find_by_user(user)
    where("user.id" => user.id).order("created_at DESC")
  end


end
