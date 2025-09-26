class GenerationArray < ApplicationRecord
  broadcasts_refreshes

  belongs_to :user

  has_many :generations, dependent: :destroy

  serialize :selected_styles, coder: JSON

  after_create do 
    styles_to_generate = selected_styles.present? && selected_styles.any? ? selected_styles : FetchStylesJob.perform_now(user)
    generations = styles_to_generate.map do |style|
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
    self.selected_styles ||= []
  end
end
