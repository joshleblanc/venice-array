class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def balances 
    response = Faraday.new(url: "https://api.venice.ai/api/v1/api_keys/rate_limits") do |faraday|
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end.get do |request|
      request.headers["Authorization"] = "Bearer #{venice_api_key}"
      request.headers["Content-Type"] = "application/json"
    end
    
    if response.status == 200 
      response.body["data"]["balances"]
    else 
      {}
    end
  end
end
