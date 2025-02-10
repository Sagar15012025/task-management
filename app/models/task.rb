class Task < ApplicationRecord
  belongs_to :user
  belongs_to :project
  has_many :comments

  enum status: { pending: 0, active: 1, completed: 2 }

  validates :status, presence: true, inclusion: { in: %w[pending active completed], message: "%{value} is not a valid status" }
  validates :title, length: { minimum: 2 }
  validates :description, presence: true, length: { maximum: 100 }

  validate :start_date_must_be_in_future

  def start_date_must_be_in_future
    if start_date.blank?
      errors.add("Start date can't be blank")
      return
    end

    if start_date <= Date.current
      errors.add(:start_date, "must be greater than today")
    end
  end
end
