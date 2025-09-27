class GenerationArraysController < ApplicationController
  before_action :set_generation_array, only: %i[ show destroy ]
  before_action :set_models, only: %i[ new create ]
  before_action :set_styles, only: %i[ new create ]

  # GET /generation_arrays or /generation_arrays.json
  def index
    @generation_arrays = policy_scope(GenerationArray.all)
    authorize(@generation_arrays)
  end

  # GET /generation_arrays/1 or /generation_arrays/1.json
  def show
  end

  # GET /generation_arrays/new
  def new
    @generation_array = GenerationArray.new
    @generation_array.user = current_user
    authorize(@generation_array)
  end

  # POST /generation_arrays or /generation_arrays.json
  def create
    @generation_array = GenerationArray.new(generation_array_params)
    @generation_array.user = Current.user
    authorize(@generation_array)

    respond_to do |format|
      if @generation_array.save
        ActiveJob.perform_all_later(@generation_array.generations.map { GenerateImageJob.new(it) })
        format.html { redirect_to @generation_array, notice: "Generation array was successfully created." }
        format.json { render :show, status: :created, location: @generation_array }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @generation_array.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /generation_arrays/1 or /generation_arrays/1.json
  def destroy
    @generation_array.destroy!

    respond_to do |format|
      format.html { redirect_to generation_arrays_path, notice: "Generation array was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_generation_array
      @generation_array = GenerationArray.find(params.expect(:id))
      authorize(@generation_array)
    end

    # Fetch models for dropdown from Venice API
    def set_models
      user = Current.user
      @model_options = FetchModelsJob.perform_now(user)
    end

    # Fetch styles for selection from Venice API
    def set_styles
      user = Current.user
      @available_styles = FetchStylesJob.perform_now(user)
    end

    # Only allow a list of trusted parameters through.
    def generation_array_params
      params.expect(generation_array: [ :prompt, :model, :cfg_scale, :lora_strength, :negative_prompt, :safe_mode, :seed, :steps, selected_styles: [] ])
    end
end
