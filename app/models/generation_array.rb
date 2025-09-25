class GenerationArray < ApplicationRecord
  belongs_to :user

  has_many :generations, dependent: :destroy

  after_initialize do 
    self.model ||= "venice-sd35"
    self.cfg_scale ||= 7.5
    self.lora_strength ||= 0.5
    self.safe_mode ||= false
    self.seed ||= rand(0..4294967295)
    self.steps ||= 25
  end
end
