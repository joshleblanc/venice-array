class FetchTraitsJob < ApplicationJob
  def perform
    Rails.cache.fetch("traits/image", expires_in: 1.day) do
      conn = Faraday.new(url: "https://api.venice.ai") do |faraday|
      faraday.response :json
      faraday.adapter Faraday.default_adapter
      end

      response = conn.get("/api/v1/models/traits?type=image") do |request|
        request.headers["Authorization"] = "Bearer #{Rails.application.credentials.venice_api_key}"
      end

      response.body["data"]
    end
  end
end
