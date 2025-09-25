class CreateGenerations < ActiveRecord::Migration[8.0]
  def change
    create_table :generations do |t|
      t.string :style_preset
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :generation_array, null: false, foreign_key: true

      t.timestamps
    end
  end
end
