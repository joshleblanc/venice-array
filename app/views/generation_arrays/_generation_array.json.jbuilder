json.extract! generation_array, :id, :prompt, :model, :cfg_scale, :lora_strength, :negative_prompt, :safe_mode, :seed, :steps, :user_id, :created_at, :updated_at
json.url generation_array_url(generation_array, format: :json)
