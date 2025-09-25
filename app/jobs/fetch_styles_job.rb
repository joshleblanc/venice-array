class FetchStylesJob < ApplicationJob
    def perform(user)

        conn = Faraday.new(url: "https://api.venice.ai") do |faraday|
        faraday.response :json
        faraday.adapter Faraday.default_adapter
        end

        response = conn.get("/api/v1/image/styles") do |request|
        if user.venice_api_key.present?
            request.headers["Authorization"] = "Bearer #{user.venice_api_key}"
        end
        end

        response.body["data"]
    end
end