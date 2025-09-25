require "application_system_test_case"

class GenerationArraysTest < ApplicationSystemTestCase
  setup do
    @generation_array = generation_arrays(:one)
  end

  test "visiting the index" do
    visit generation_arrays_url
    assert_selector "h1", text: "Generation arrays"
  end

  test "should create generation array" do
    visit generation_arrays_url
    click_on "New generation array"

    fill_in "Cfg scale", with: @generation_array.cfg_scale
    fill_in "Lora strength", with: @generation_array.lora_strength
    fill_in "Model", with: @generation_array.model
    fill_in "Negative prompt", with: @generation_array.negative_prompt
    fill_in "Prompt", with: @generation_array.prompt
    check "Safe mode" if @generation_array.safe_mode
    fill_in "Seed", with: @generation_array.seed
    fill_in "Steps", with: @generation_array.steps
    fill_in "User", with: @generation_array.user_id
    click_on "Create Generation array"

    assert_text "Generation array was successfully created"
    click_on "Back"
  end

  test "should update Generation array" do
    visit generation_array_url(@generation_array)
    click_on "Edit this generation array", match: :first

    fill_in "Cfg scale", with: @generation_array.cfg_scale
    fill_in "Lora strength", with: @generation_array.lora_strength
    fill_in "Model", with: @generation_array.model
    fill_in "Negative prompt", with: @generation_array.negative_prompt
    fill_in "Prompt", with: @generation_array.prompt
    check "Safe mode" if @generation_array.safe_mode
    fill_in "Seed", with: @generation_array.seed
    fill_in "Steps", with: @generation_array.steps
    fill_in "User", with: @generation_array.user_id
    click_on "Update Generation array"

    assert_text "Generation array was successfully updated"
    click_on "Back"
  end

  test "should destroy Generation array" do
    visit generation_array_url(@generation_array)
    accept_confirm { click_on "Destroy this generation array", match: :first }

    assert_text "Generation array was successfully destroyed"
  end
end
