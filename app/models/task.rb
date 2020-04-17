class Task < ApplicationRecord
  has_many :task_items
  belongs_to :user
  belongs_to :provider, class_name: "User", foreign_key: 'provider_id', optional: true
  enum status: [:pending, :confirmed, :claimed, :finalized]

  def is_confirmable?(user)
    task_items.count < 40 && task_items.count >= 5 && self.user == user
  end

  def is_claimable?(user)
    status != 'claimed' && self.user != user
  end
end
