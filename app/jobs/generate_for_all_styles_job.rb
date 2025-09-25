class GenerateForAllStylesJob < ApplicationJob
  queue_as :default

  def perform(generation_array)
    user = generation_array.user

    conn = Faraday.new(url: "https://api.venice.ai") do |faraday|
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end

    response = conn.get("/api/v1/image/styles") do |request|
      if user.venice_api_key.present?
        request.headers["Authorization"] = "Bearer #{user.venice_api_key}"
      end
    end

    styles = response.body["data"]

    styles.each do |style|
      generation = Generation.create!(
        user: user,
        generation_array: generation_array,
        style_preset: style
      )
      GenerateImageJob.perform_later(generation)
    end
  rescue => e
    Rails.logger.error("GenerateForAllStylesJob failed for GenerationArray##{generation_array.id}: #{e.class} #{e.message}")
  end
end
