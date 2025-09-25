class GenerationArraysController < ApplicationController
  before_action :set_generation_array, only: %i[ show edit update destroy ]
  before_action :set_models, only: %i[ new edit create update ]

  # GET /generation_arrays or /generation_arrays.json
  def index
    @generation_arrays = GenerationArray.all
  end

  # GET /generation_arrays/1 or /generation_arrays/1.json
  def show
  end

  # GET /generation_arrays/new
  def new
    @generation_array = GenerationArray.new
  end

  # GET /generation_arrays/1/edit
  def edit
  end

  # POST /generation_arrays or /generation_arrays.json
  def create
    @generation_array = GenerationArray.new(generation_array_params)
    @generation_array.user = Current.user

    respond_to do |format|
      if @generation_array.save
        GenerateForAllStylesJob.perform_later(@generation_array)
        format.html { redirect_to @generation_array, notice: "Generation array was successfully created." }
        format.json { render :show, status: :created, location: @generation_array }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @generation_array.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /generation_arrays/1 or /generation_arrays/1.json
  def update
    respond_to do |format|
      if @generation_array.update(generation_array_params)
        format.html { redirect_to @generation_array, notice: "Generation array was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @generation_array }
      else
        format.html { render :edit, status: :unprocessable_entity }
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
    end

    # Fetch models for dropdown from Venice API
    def set_models
      @model_options = []
      user = Current.user
      begin
        conn = Faraday.new(url: "https://api.venice.ai") do |faraday|
          faraday.response :json
          faraday.adapter Faraday.default_adapter
        end
        response = conn.get("/api/v1/models?type=image") do |request|
          request.headers["Authorization"] = "Bearer #{user.venice_api_key}" if user&.venice_api_key.present?
        end
        list = response.body["data"]
        @model_options = list.map do |item|
          [item["model_spec"]["name"], item["id"]]
        end.compact
      rescue => e
        Rails.logger.error("Failed to fetch models: #{e.class} #{e.message}")
        @model_options ||= []
      end
    end

    # Only allow a list of trusted parameters through.
    def generation_array_params
      params.expect(generation_array: [ :prompt, :model, :cfg_scale, :lora_strength, :negative_prompt, :safe_mode, :seed, :steps ])
    end
  end
