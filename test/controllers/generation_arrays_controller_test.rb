require "test_helper"

class GenerationArraysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @generation_array = generation_arrays(:one)
  end

  test "should get index" do
    get generation_arrays_url
    assert_response :success
  end

  test "should get new" do
    get new_generation_array_url
    assert_response :success
  end

  test "should create generation_array" do
    assert_difference("GenerationArray.count") do
      post generation_arrays_url, params: { generation_array: { cfg_scale: @generation_array.cfg_scale, lora_strength: @generation_array.lora_strength, model: @generation_array.model, negative_prompt: @generation_array.negative_prompt, prompt: @generation_array.prompt, safe_mode: @generation_array.safe_mode, seed: @generation_array.seed, steps: @generation_array.steps, user_id: @generation_array.user_id } }
    end

    assert_redirected_to generation_array_url(GenerationArray.last)
  end

  test "should show generation_array" do
    get generation_array_url(@generation_array)
    assert_response :success
  end

  test "should get edit" do
    get edit_generation_array_url(@generation_array)
    assert_response :success
  end

  test "should update generation_array" do
    patch generation_array_url(@generation_array), params: { generation_array: { cfg_scale: @generation_array.cfg_scale, lora_strength: @generation_array.lora_strength, model: @generation_array.model, negative_prompt: @generation_array.negative_prompt, prompt: @generation_array.prompt, safe_mode: @generation_array.safe_mode, seed: @generation_array.seed, steps: @generation_array.steps, user_id: @generation_array.user_id } }
    assert_redirected_to generation_array_url(@generation_array)
  end

  test "should destroy generation_array" do
    assert_difference("GenerationArray.count", -1) do
      delete generation_array_url(@generation_array)
    end

    assert_redirected_to generation_arrays_url
  end
end
