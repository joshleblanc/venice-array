class Generation < ApplicationRecord
  belongs_to :user
  belongs_to :generation_array, touch: true

  has_one_attached :image do 
    it.variant :thumb, resize_to_limit: [128, 128], preprocessed: true 
  end
end
