class GenerationArray < ApplicationRecord
  broadcasts_refreshes

  belongs_to :user

  has_many :generations, dependent: :destroy

  after_initialize do 
    self.model ||= "venice-sd35"
    self.cfg_scale ||= 5
    self.lora_strength ||= 75
    self.safe_mode ||= false
    self.seed ||= rand(0..999999999)
    self.steps ||= 25
  end
end
