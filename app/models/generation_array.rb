class GenerationArray < ApplicationRecord
  broadcasts_refreshes

  belongs_to :user

  has_many :generations, dependent: :destroy

  after_create do 
    generations = FetchStylesJob.perform_now(user).map do |style|
      Generation.new(style_preset: style, user: user, generation_array: self)
    end
    Generation.import(generations)
    touch
  end

  after_initialize do 
    self.model ||= "venice-sd35"
    self.cfg_scale ||= 5
    self.lora_strength ||= 75
    self.safe_mode ||= false
    self.seed ||= rand(0..999999999)
    self.steps ||= 25
  end
end
