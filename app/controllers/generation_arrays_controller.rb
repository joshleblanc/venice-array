class GenerationArraysController < ApplicationController
  before_action :set_generation_array, only: %i[ show destroy copy ]
  before_action :set_models, only: %i[ new create copy ]
  before_action :set_styles, only: %i[ new create copy ]


  # GET /generation_arrays or /generation_arrays.json
  def index
    @generation_arrays = policy_scope(GenerationArray.all.order(created_at: :desc))
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

  # GET /generation_arrays/1/copy
  def copy
    # Create a new generation array with copied settings
    @generation_array = GenerationArray.new(
      prompt: @generation_array.prompt,
      negative_prompt: @generation_array.negative_prompt,
      image_model: @generation_array.image_model,
      cfg_scale: @generation_array.cfg_scale,
      lora_strength: @generation_array.lora_strength,
      safe_mode: @generation_array.safe_mode,
      steps: @generation_array.steps,
      selected_styles: @generation_array.selected_styles,
      user: current_user
    )
    
    # Generate a new random seed for the copy
    @generation_array.seed = rand(0..999999999)
    
    authorize(@generation_array)
    render :new
  end

  # POST /generation_arrays or /generation_arrays.json
  def create
    @generation_array = GenerationArray.new(generation_array_params)
    @generation_array.user = Current.user

    if generation_array_params[:seed].empty?
      @generation_array.seed = nil
    end

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

  def sync_models
    authorize(GenerationArray)
    FetchModelsJob.perform_later
    redirect_back fallback_location: new_generation_array_path, notice: "Model sync started. Refresh in a moment to see updates."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_generation_array
      @generation_array = GenerationArray.find(params.expect(:id))
      authorize(@generation_array)
    end

    # Fetch models for dropdown from Venice API
    def set_models
      @image_models = ImageModel.all
    end

    # Fetch styles for selection from Venice API
    def set_styles
      user = Current.user
      @available_styles = FetchStylesJob.perform_now(user)
    end

    # Only allow a list of trusted parameters through.
    def generation_array_params
      params.expect(generation_array: [ :prompt, :image_model_id, :cfg_scale, :lora_strength, :negative_prompt, :safe_mode, :seed, :steps, selected_styles: [] ])
    end
end
