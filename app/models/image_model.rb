class ImageModel < ApplicationRecord
  store_accessor :model_spec, :name, :constraints
end
