class GenerationArray < ApplicationRecord
  belongs_to :user

  has_many :generations, dependent: :destroy
end
