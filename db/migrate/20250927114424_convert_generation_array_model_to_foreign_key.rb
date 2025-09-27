class ConvertGenerationArrayModelToForeignKey < ActiveRecord::Migration[8.0]
  def up
    # Ensure FetchModelsJob has run to populate ImageModel records
    puts "Ensuring ImageModel records are up to date..."
    FetchModelsJob.perform_now
    
    # Add the new foreign key column
    add_reference :generation_arrays, :image_model, null: true, foreign_key: true
    
    # Update existing records to link to ImageModel records
    puts "Converting existing model strings to foreign keys..."
    GenerationArray.reset_column_information
    
    GenerationArray.find_each do |ga|
      if ga.model.present?
        image_model = ImageModel.find_by(external_id: ga.model)
        if image_model
          ga.update_column(:image_model_id, image_model.id)
          puts "Updated GenerationArray #{ga.id}: #{ga.model} -> ImageModel #{image_model.id}"
        else
          puts "WARNING: No ImageModel found for model '#{ga.model}' in GenerationArray #{ga.id}"
        end
      end
    end
    
    # Check if all records were successfully converted
    unconverted_count = GenerationArray.where(image_model_id: nil).where.not(model: [nil, '']).count
    if unconverted_count > 0
      puts "WARNING: #{unconverted_count} GenerationArray records could not be converted"
      puts "These records have model values that don't match any ImageModel external_id"
    end
    
    # Make the foreign key required after conversion
    change_column_null :generation_arrays, :image_model_id, false
    
    # Remove the old string column
    remove_column :generation_arrays, :model, :string
    
    puts "Migration completed successfully!"
  end
  
  def down
    # Add back the string column
    add_column :generation_arrays, :model, :string
    
    # Convert foreign keys back to strings
    GenerationArray.reset_column_information
    
    GenerationArray.includes(:image_model).find_each do |ga|
      if ga.image_model
        ga.update_column(:model, ga.image_model.external_id)
      end
    end
    
    # Remove the foreign key
    remove_reference :generation_arrays, :image_model, foreign_key: true
  end
end
