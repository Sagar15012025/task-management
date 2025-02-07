class Comment < ApplicationRecord
  validates :content, length: { in: 2..500 }
end
