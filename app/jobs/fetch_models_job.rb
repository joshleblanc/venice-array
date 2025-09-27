class FetchModelsJob < ApplicationJob
    def perform
        begin
            conn = Faraday.new(url: "https://api.venice.ai") do |faraday|
                faraday.response :json
                faraday.adapter Faraday.default_adapter
            end
            response = conn.get("/api/v1/models?type=image") do |request|
                request.headers["Authorization"] = "Bearer #{Rails.application.credentials[:venice_api_key]}"
            end
            list = response.body["data"]
            list.each do |item|
                im = ImageModel.where(external_id: item["id"]).first_or_initialize
                im.model_spec = item["model_spec"]
                im.save
            end.compact
        rescue => e
            Rails.logger.error("Failed to fetch models: #{e.class} #{e.message}")
            []
        end
    end
end
