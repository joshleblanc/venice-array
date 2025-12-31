class ImageModel < ApplicationRecord
  store_accessor :model_spec, :name, :constraints, :pricing

  def generation_pricing
    p = pricing.is_a?(Hash) ? pricing : {}
    g = p["generation"].is_a?(Hash) ? p["generation"] : {}

    {
      "USD" => g["usd"],
      "DIEM" => g["diem"]
    }.compact
  end
end
