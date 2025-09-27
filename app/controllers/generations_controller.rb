class GenerationsController < ApplicationController
  before_action :set_generation, only: %i[ show ]

  # GET /generations or /generations.json
  def index
    if params[:generation_array_id]
      @generation_array = GenerationArray.find(params[:generation_array_id])
      @generations = @generation_array.generations.order(created_at: :asc)
    else
      @generations = Generation.where(user: current_user).all
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_generation
      @generation = Generation.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def generation_params
      params.expect(generation: [ :style_preset, :user_id, :generation_array_id ])
    end
end
