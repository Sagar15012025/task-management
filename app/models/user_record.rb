class User < ApplicationRecord
  has_many :projects
  has_many :tasks
  has_many :comments

  enum role: { user: 0, admin: 1 }

  validates :name, length: { minimum: 2 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { in: 6..20 }
  validates :role, inclusion: { in: %w[user admin], message: "%{value} is not a valid role" }
end
