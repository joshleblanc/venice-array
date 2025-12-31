json.extract! generation_array, :id, :prompt, :cfg_scale, :lora_strength, :negative_prompt, :safe_mode, :seed, :steps, :user_id, :created_at, :updated_at
json.image_model do
  json.id generation_array.image_model_id
  json.external_id generation_array.image_model.external_id
  json.name generation_array.image_model.name
end

json.estimated_generation_count generation_array.estimated_generation_count
json.estimated_cost_per_image generation_array.estimated_cost_per_image
json.estimated_total_cost generation_array.estimated_total_cost
json.url generation_array_url(generation_array, format: :json)
