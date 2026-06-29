require_relative '../test_helper'
require_relative '../../lib/academic_calendar_information'
require_relative '../../lib/day_attribute'

class AcademicCalendarInformationTest < Minitest::Test
    def setup
        @valid_date = Date.new(2024, 6, 1)
        @valid_day_of_the_week = :mon
        @valid_term = 1
        @valid_day_attribute = DayAttribute.new(day_of_the_week_changes: nil, is_makeup_class: false, is_exam_period: false, is_public_holiday: false, is_holiday: false, comments: nil)
    end

    def test_valid_initialization
        info = AcademicCalendarInformation.new(
            date: @valid_date,
            day_of_the_week: @valid_day_of_the_week,
            term: @valid_term,
            day_attribute: @valid_day_attribute
        )
        assert_equal @valid_date, info.date
        assert_equal @valid_day_of_the_week, info.day_of_the_week
        assert_equal @valid_term, info.term
        assert_equal @valid_day_attribute, info.day_attribute
    end

    def test_valid_boundary_term_values
        zero_term = AcademicCalendarInformation.new(
            date: @valid_date,
            day_of_the_week: @valid_day_of_the_week,
            term: 0,
            day_attribute: @valid_day_attribute
        )

        negative_term = AcademicCalendarInformation.new(
            date: @valid_date,
            day_of_the_week: @valid_day_of_the_week,
            term: -1,
            day_attribute: @valid_day_attribute
        )

        assert_equal 0, zero_term.term
        assert_equal(-1, negative_term.term)
    end

    def test_invalid_date
        assert_raises(TypeError) do
            AcademicCalendarInformation.new(
                date: "not a date",
                day_of_the_week: @valid_day_of_the_week,
                term: @valid_term,
                day_attribute: @valid_day_attribute
            )
        end
    end

    def test_invalid_day_of_the_week
        assert_raises(TypeError) do
            AcademicCalendarInformation.new(
                date: @valid_date,
                day_of_the_week: "Monday",
                term: @valid_term,
                day_attribute: @valid_day_attribute
            )
    end
    end

    def test_invalid_term
        assert_raises(TypeError) do
            AcademicCalendarInformation.new(
                date: @valid_date,
                day_of_the_week: @valid_day_of_the_week,
                term: "First Term",
                day_attribute: @valid_day_attribute
            )
        end
    end

    def test_invalid_day_attribute
        assert_raises(TypeError) do
            AcademicCalendarInformation.new(
                date: @valid_date,
                day_of_the_week: @valid_day_of_the_week,
                term: @valid_term,
                day_attribute: "not a day attribute"
            )
        end
    end

    def test_invalid_day_attribute_nil
        assert_raises(TypeError) do
            AcademicCalendarInformation.new(
                date: @valid_date,
                day_of_the_week: @valid_day_of_the_week,
                term: @valid_term,
                day_attribute: nil
            )
        end
    end
end
