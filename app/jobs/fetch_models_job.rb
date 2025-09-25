class FetchModelsJob < ApplicationJob 
    def perform(user)
        Rails.cache.fetch("models", expires_in: 1.day) do
            conn = Faraday.new(url: "https://api.venice.ai") do |faraday|
                faraday.response :json
                faraday.adapter Faraday.default_adapter
            end
            response = conn.get("/api/v1/models?type=image") do |request|
                request.headers["Authorization"] = "Bearer #{user.venice_api_key}" if user&.venice_api_key.present?
            end
            list = response.body["data"]
            list.map do |item|
                [item["model_spec"]["name"], item["id"]]
            end.compact
        rescue => e
            Rails.logger.error("Failed to fetch models: #{e.class} #{e.message}")
            []
        end
    end
end