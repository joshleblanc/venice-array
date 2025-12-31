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
    next if persisted?
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

  def estimated_generation_count
    return generations.size if association(:generations).loaded?
    return generations.count if persisted?
    return selected_styles.size if selected_styles.present? && selected_styles.any?

    nil
  end

  def estimated_cost_per_image
    base = image_model.generation_pricing
    return {} if base.blank?

    default_steps = image_model.constraints.dig("steps", "default")
    factor = (default_steps.to_f > 0) ? (steps.to_f / default_steps.to_f) : 1.0

    base.transform_values { |v| v.to_f * factor }
  end

  def estimated_total_cost
    count = estimated_generation_count
    return {} if count.blank?

    estimated_cost_per_image.transform_values { |v| v.to_f * count.to_i }
  end
end
