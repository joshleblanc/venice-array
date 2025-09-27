class CreateImageModels < ActiveRecord::Migration[8.0]
  def change
    create_table :image_models do |t|
      t.string :external_id
      t.json :model_spec

      t.timestamps
    end
  end
end
