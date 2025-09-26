class AddSelectedStylesToGenerationArrays < ActiveRecord::Migration[8.0]
  def change
    add_column :generation_arrays, :selected_styles, :text
  end
end
