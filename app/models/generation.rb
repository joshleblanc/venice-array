class Generation < ApplicationRecord
  after_update_commit -> { broadcast_update_to generation_array }

  belongs_to :user
  belongs_to :generation_array

  has_one_attached :image do
    it.variant :thumb, resize_to_limit: [ 256, 256 ], preprocessed: true
  end
end
