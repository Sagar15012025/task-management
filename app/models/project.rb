class Project < ApplicationRecord
  before_save :format_name_and_description

  belongs_to :assignee, class_name: "User", foreign_key: "assignee_id"
  has_many :tasks

  enum :current_status, STATUS[:project], default: :pending

  validates :name, length: { minimum: 10 }
  validates :description, presence: true, length: { maximum: 100 }
  validates :current_status, inclusion: { in: %w[pending active completed], message: "%{value} is not a valid status" }

  private
  def format_name_and_description
    self.name = name.humanize.titleize
    self.description = description.upcase_first
  end
end
