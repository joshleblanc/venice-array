class GenerateImageJob < ApplicationJob
  class RateLimitError < StandardError; end

  limits_concurrency to: 4, key: ->(generation) { generation.generation_array }
  queue_as :default

  queue_with_priority 10

  def perform(generation)
    user = generation.user
    ga = generation.generation_array

    body = {
      model: ga.image_model.external_id,
      prompt: ga.prompt,
      negative_prompt: ga.negative_prompt,
      cfg_scale: ga.cfg_scale,
      steps: ga.steps,
      # seed: ga.seed,
      safe_mode: ga.safe_mode,
      lora_strength: ga.lora_strength,
      style_preset: generation.style_preset,
      width: 1024,
      height: 1024
    }.compact

    response = Faraday.new(url: "https://api.venice.ai/api/v1/image/generate") do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end.post do |request|
      request.headers["Authorization"] = "Bearer #{user.venice_api_key}"
      request.headers["Content-Type"] = "application/json"
      request.body = body.to_json
    end

    if response.status != 200
      Rails.logger.error("Failed to generate image: #{response.body}")
      raise RateLimitError.new
    end

    base64_data = response.body["images"].first
    image_data = Base64.decode64(base64_data)
    string_io = StringIO.new(image_data)
    string_io.set_encoding(Encoding::BINARY)
    generation.image.attach(io: string_io, filename: "#{generation.style_preset}.webp", content_type: "image/webp")
  end
end
