class Generation < ApplicationRecord
  belongs_to :user
  belongs_to :generation_array

  has_one_attached :image
end
