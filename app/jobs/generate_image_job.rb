class GenerateImageJob < ApplicationJob
  queue_as :default

  def perform(user, body)
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
