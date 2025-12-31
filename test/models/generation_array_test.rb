require "test_helper"

class GenerationArrayTest < ActiveSupport::TestCase
  test "estimated costs use model pricing and step factor" do
    ga = generation_arrays(:one)

    assert_equal 1, ga.estimated_generation_count

    per = ga.estimated_cost_per_image
    total = ga.estimated_total_cost

    assert_in_delta 0.01 * (1.0 / 25.0), per["USD"], 0.0000001
    assert_in_delta 0.02 * (1.0 / 25.0), per["DIEM"], 0.0000001

    assert_in_delta per["USD"], total["USD"], 0.0000001
    assert_in_delta per["DIEM"], total["DIEM"], 0.0000001
  end

  test "estimated generation count uses selected styles for unsaved records" do
    ga = GenerationArray.new(
      prompt: "Test",
      user: users(:one),
      image_model: image_models(:one),
      steps: 25,
      selected_styles: ["A", "B"]
    )

    assert_equal 2, ga.estimated_generation_count

    per = ga.estimated_cost_per_image
    total = ga.estimated_total_cost

    assert_in_delta 0.01, per["USD"], 0.0000001
    assert_in_delta 0.02, per["DIEM"], 0.0000001

    assert_in_delta 0.02, total["USD"], 0.0000001
    assert_in_delta 0.04, total["DIEM"], 0.0000001
  end
end
