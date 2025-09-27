class GenerationArray < ApplicationRecord
  belongs_to :user
  belongs_to :image_model

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
    self.image_model ||= ImageModel.find_by(external_id: FetchTraitsJob.perform_now["default"])
    self.cfg_scale ||= 5
    self.lora_strength ||= 75
    self.safe_mode ||= false
    self.seed ||= rand(0..999999999)
    self.steps ||= 25
    self.selected_styles ||= []
  end

  validate do
    image_model.constraints.each do |key, value|
      if key == "promptCharacterLimit"
        errors.add(:prompt, "must be less than or equal to #{value} characters") if prompt.length > value
      elsif key == "steps"
        errors.add(:steps, "must be less than or equal to #{value["max"]}") if steps > value["max"]
      end
    end
  end
end
