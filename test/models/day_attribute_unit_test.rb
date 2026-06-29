require_relative '../test_helper'
require_relative '../../lib/day_attribute'

class DayAttributeTest < Minitest::Test
    def setup
        @valid_day_of_the_week_changes = nil
        @valid_is_makeup_class = false
        @valid_is_exam_period = false
        @valid_is_public_holiday = false
        @valid_is_holiday = false
        @valid_comments = nil
    end

    def test_valid_initialization
        attr = DayAttribute.new(
            day_of_the_week_changes: @valid_day_of_the_week_changes,
            is_makeup_class: @valid_is_makeup_class,
            is_exam_period: @valid_is_exam_period,
            is_public_holiday: @valid_is_public_holiday,
            is_holiday: @valid_is_holiday,
            comments: @valid_comments
        )
        assert_nil attr.day_of_the_week_changes
        assert_equal @valid_is_makeup_class, attr.is_makeup_class
        assert_equal @valid_is_exam_period, attr.is_exam_period
        assert_equal @valid_is_public_holiday, attr.is_public_holiday
        assert_equal @valid_is_holiday, attr.is_holiday
        assert_nil attr.comments
    end

    def test_valid_comments_array
        attr = DayAttribute.new(
            day_of_the_week_changes: :tue,
            is_makeup_class: true,
            is_exam_period: false,
            is_public_holiday: false,
            is_holiday: false,
            comments: ["Classes moved to Tuesday", "Bring notes"]
        )

        assert_equal [:tue, true, false, false, false, ["Classes moved to Tuesday", "Bring notes"]], [
            attr.day_of_the_week_changes,
            attr.is_makeup_class,
            attr.is_exam_period,
            attr.is_public_holiday,
            attr.is_holiday,
            attr.comments
        ]
    end

    def test_valid_empty_comments_array
        attr = DayAttribute.new(
            day_of_the_week_changes: nil,
            is_makeup_class: false,
            is_exam_period: false,
            is_public_holiday: false,
            is_holiday: false,
            comments: []
        )

        assert_equal [], attr.comments
    end

    def test_invalid_day_of_the_week_changes
        assert_raises(TypeError) do
            DayAttribute.new(
                day_of_the_week_changes: "Monday",
                is_makeup_class: @valid_is_makeup_class,
                is_exam_period: @valid_is_exam_period,
                is_public_holiday: @valid_is_public_holiday,
                is_holiday: @valid_is_holiday,
                comments: @valid_comments
            )
        end
    end

    def test_invalid_is_makeup_class
        assert_raises(TypeError) do
            DayAttribute.new(
                day_of_the_week_changes: @valid_day_of_the_week_changes,
                is_makeup_class: "false",
                is_exam_period: @valid_is_exam_period,
                is_public_holiday: @valid_is_public_holiday,
                is_holiday: @valid_is_holiday,
                comments: @valid_comments
            )
        end
    end

    def test_invalid_is_exam_period
        assert_raises(TypeError) do
            DayAttribute.new(
                day_of_the_week_changes: @valid_day_of_the_week_changes,
                is_makeup_class: @valid_is_makeup_class,
                is_exam_period: "false",
                is_public_holiday: @valid_is_public_holiday,
                is_holiday: @valid_is_holiday,
                comments: @valid_comments
            )
        end
    end

    def test_invalid_is_public_holiday
        assert_raises(TypeError) do
            DayAttribute.new(
                day_of_the_week_changes: @valid_day_of_the_week_changes,
                is_makeup_class: @valid_is_makeup_class,
                is_exam_period: @valid_is_exam_period,
                is_public_holiday: "false",
                is_holiday: @valid_is_holiday,
                comments: @valid_comments
            )
        end
    end

    def test_invalid_is_holiday
        assert_raises(TypeError) do
            DayAttribute.new(
                day_of_the_week_changes: @valid_day_of_the_week_changes,
                is_makeup_class: @valid_is_makeup_class,
                is_exam_period: @valid_is_exam_period,
                is_public_holiday: @valid_is_public_holiday,
                is_holiday: "false",
                comments: @valid_comments
            )
        end
    end

    def test_invalid_comments
        assert_raises(TypeError) do
            DayAttribute.new(
                day_of_the_week_changes: @valid_day_of_the_week_changes,
                is_makeup_class: @valid_is_makeup_class,
                is_exam_period: @valid_is_exam_period,
                is_public_holiday: @valid_is_public_holiday,
                is_holiday: @valid_is_holiday,
                comments: 123
            )
        end
    end

    def test_invalid_comments_contents
        assert_raises(TypeError) do
            DayAttribute.new(
                day_of_the_week_changes: @valid_day_of_the_week_changes,
                is_makeup_class: @valid_is_makeup_class,
                is_exam_period: @valid_is_exam_period,
                is_public_holiday: @valid_is_public_holiday,
                is_holiday: @valid_is_holiday,
                comments: ["ok", 123]
            )
        end
    end

    def test_valid_nil_comments
        attr = DayAttribute.new(
            day_of_the_week_changes: nil,
            is_makeup_class: false,
            is_exam_period: false,
            is_public_holiday: false,
            is_holiday: false,
            comments: nil
        )

        assert_nil attr.comments
    end
end

    
