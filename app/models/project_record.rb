class Project < ApplicationRecord
  belongs_to :user

  has_many :tasks

  enum status: { pending: 0, active: 1, completed: 2 }

  validates :name, length: { minimum: 10 }
  validates :description, presence: true, length: { maximum: 100 }
  validates :status, inclusion: { in: %w[pending active completed], message: "%{value} is not a valid status" }
end
