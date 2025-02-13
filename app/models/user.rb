class User < ApplicationRecord
  has_encrypted :email, :password

  has_many :projects
  has_many :tasks
  has_many :comments

  validates :name, length: { minimum: 2 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { in: 6..20 }
end
