class FetchStylesJob < ApplicationJob
    def perform(user)
        Faraday.new(url: "https://api.venice.ai/api/v1/image/styles") do |faraday|
            faraday.response :json
            faraday.adapter Faraday.default_adapter
        end.get do |request|
            request.headers["Authorization"] = "Bearer #{user.venice_api_key}"
        end
    end
end