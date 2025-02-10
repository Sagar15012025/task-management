class Project < ApplicationRecord
  belongs_to :assignee, class_name: "User", foreign_key: "assignee_id"
  has_many :tasks

  enum :current_status, [ :pending, :active, :completed ], default: :pending

  validates :name, length: { minimum: 10 }
  validates :description, presence: true, length: { maximum: 100 }
  validates :current_status, inclusion: { in: %w[pending active completed], message: "%{value} is not a valid status" }
end
