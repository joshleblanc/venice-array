class GenerateForAllStylesJob < ApplicationJob
  queue_as :default

  def perform(generation_array)
    styles = FetchStylesJob.perform_now

    ActiveJob.perform_all
    GenerateImageJob.perform_later(generation)
    generation_array.generations.find_each do |generation|

    end
    styles.each do |style|
      generation = Generation.create!(
        user: user,
        generation_array: generation_array,
        style_preset: style
      )
    end
  rescue => e
    Rails.logger.error("GenerateForAllStylesJob failed for GenerationArray##{generation_array.id}: #{e.class} #{e.message}")
  end
end
