class Task < ApplicationRecord
  belongs_to :assignee, class_name: "User", foreign_key: "assignee_id"
  belongs_to :project
  has_many :comments

  enum :status, [ :pending, :active, :completed ], default: :pending

  validates :status, presence: true, inclusion: { in: %w[pending active completed], message: "%{value} is not a valid status" }
  validates :title, length: { minimum: 2 }
  validates :description, presence: true, length: { maximum: 100 }

  validates_associated :project, :assignee

  validate :due_date_must_be_in_future

  private

  def due_date_must_be_in_future
    if due_date.blank?
      errors.add("Start date can't be blank")
      return
    end

    if due_date <= Date.current
      errors.add(:due_date, "must be greater than today")
    end
  end
end
