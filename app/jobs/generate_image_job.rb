class GenerateImageJob < ApplicationJob
  queue_as :default

  def perform(generation)
    user = generation.user
    ga = generation.generation_array

    body = {
      model: ga.model,
      prompt: ga.prompt,
      negative_prompt: ga.negative_prompt,
      cfg_scale: ga.cfg_scale,
      steps: ga.steps,
      seed: ga.seed,
      safe_mode: ga.safe_mode,
      lora_strength: ga.lora_strength,
      style_preset: generation.style_preset
    }.compact

    Faraday.new(url: "https://api.venice.ai/api/v1/image/generate") do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end.post do |request|
      request.headers["Authorization"] = "Bearer #{user.venice_api_key}"
      request.headers["Content-Type"] = "application/json"
      request.body = body.to_json
    end
  end
end
