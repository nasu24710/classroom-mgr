require_relative '../test_helper'
require_relative '../../lib/academic_calendar_information_repository'
require_relative '../../lib/academic_calendar_information'
require_relative '../../lib/day_attribute'

class AcademicCalendarInformationRepositoryTest < Minitest::Test
    def setup
        @day_attribute = DayAttribute.new(
            day_of_the_week_changes: nil,
            is_makeup_class: false,
            is_exam_period: false,
            is_public_holiday: false,
            is_holiday: false,
            comments: nil
        )

        @monday_info = AcademicCalendarInformation.new(
            date: Date.new(2024, 6, 3),
            day_of_the_week: :mon,
            term: 1,
            day_attribute: @day_attribute
        )

        @tuesday_info = AcademicCalendarInformation.new(
            date: Date.new(2024, 6, 4),
            day_of_the_week: :tue,
            term: 1,
            day_attribute: @day_attribute
        )
    end

    def test_initialize_and_find_all
        repository = AcademicCalendarInformationRepository.new(
            academic_calendar_informations: [@monday_info]
        )

        assert_equal [@monday_info], repository.find_all
    end

    def test_find_all_returns_copy
        repository = AcademicCalendarInformationRepository.new(
            academic_calendar_informations: [@monday_info]
        )

        result = repository.find_all
        result << @tuesday_info

        assert_equal [@monday_info], repository.find_all
    end

    def test_add_and_replace_all
        repository = AcademicCalendarInformationRepository.new
        repository.replace_all([@monday_info, @tuesday_info])

        assert_equal [@monday_info, @tuesday_info], repository.find_all
    end

    def test_find_by_day_of_the_week
        repository = AcademicCalendarInformationRepository.new(
            academic_calendar_informations: [@monday_info, @tuesday_info]
        )

        assert_equal [@monday_info], repository.find_by_day_of_the_week(:mon)
    end

    def test_find_by_day_of_the_week_uses_day_attribute_change_when_present
        changed_day_attribute = DayAttribute.new(
            day_of_the_week_changes: :wed,
            is_makeup_class: false,
            is_exam_period: false,
            is_public_holiday: false,
            is_holiday: false,
            comments: nil
        )

        changed_info = AcademicCalendarInformation.new(
            date: Date.new(2024, 6, 5),
            day_of_the_week: :tue,
            term: 1,
            day_attribute: changed_day_attribute
        )

        repository = AcademicCalendarInformationRepository.new(
            academic_calendar_informations: [changed_info]
        )

        assert_equal [changed_info], repository.find_by_day_of_the_week(:wed)
        assert_equal [], repository.find_by_day_of_the_week(:tue)
    end

    def test_find_by_day_of_the_week_with_multiple_matches
        another_monday_info = AcademicCalendarInformation.new(
            date: Date.new(2024, 6, 10),
            day_of_the_week: :mon,
            term: 2,
            day_attribute: @day_attribute
        )

        repository = AcademicCalendarInformationRepository.new(
            academic_calendar_informations: [@monday_info, @tuesday_info, another_monday_info]
        )

        assert_equal [@monday_info, another_monday_info], repository.find_by_day_of_the_week(:mon)
    end

    def test_find_by_day_of_the_week_with_no_matches
        repository = AcademicCalendarInformationRepository.new(
            academic_calendar_informations: [@monday_info]
        )

        assert_equal [], repository.find_by_day_of_the_week(:tue)
    end

    def test_invalid_find_by_day_of_the_week
        repository = AcademicCalendarInformationRepository.new

        assert_raises(TypeError) do
            repository.find_by_day_of_the_week('mon')
        end
    end

    def test_invalid_initialization_argument
        assert_raises(TypeError) do
            AcademicCalendarInformationRepository.new(academic_calendar_informations: 'not an array')
        end
    end

    def test_replace_all_with_empty_array
        repository = AcademicCalendarInformationRepository.new(academic_calendar_informations: [@monday_info])
        repository.replace_all([])

        assert_equal [], repository.find_all
    end

    def test_invalid_replace_all_argument
        repository = AcademicCalendarInformationRepository.new

        assert_raises(TypeError) do
            repository.replace_all('not an array')
        end
    end
end
