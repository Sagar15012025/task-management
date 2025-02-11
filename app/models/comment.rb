class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :task

  validates :content, length: { in: 2..500 }

  validates_associated :user, :task
end
