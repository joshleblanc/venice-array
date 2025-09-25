class CreateGenerationArrays < ActiveRecord::Migration[8.0]
  def change
    create_table :generation_arrays do |t|
      t.string :prompt
      t.string :model
      t.float :cfg_scale
      t.integer :lora_strength
      t.string :negative_prompt
      t.boolean :safe_mode
      t.integer :seed
      t.integer :steps
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
