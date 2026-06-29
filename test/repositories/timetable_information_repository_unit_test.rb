require_relative '../test_helper'
require_relative '../../lib/timetable_information_repository'
require_relative '../../lib/timetable_information'

class TimetableInformationRepositoryTest < Minitest::Test
    def setup
        @timetable_a = TimetableInformation.new(
            subject: 'Mathematics',
            term: 1,
            day_of_the_week: :mon,
            periods: [:p1, :p2],
            user: 'John Doe',
            room_names: ['Room A']
        )

        @timetable_b = TimetableInformation.new(
            subject: 'Physics',
            term: 2,
            day_of_the_week: :tue,
            periods: [:p3],
            user: 'Jane Doe',
            room_names: ['Room B']
        )
    end

    def test_initialize_and_find_all
        repository = TimetableInformationRepository.new(
            timetable_informations: [@timetable_a]
        )

        assert_equal [@timetable_a], repository.find_all
    end

    def test_find_all_returns_copy
        repository = TimetableInformationRepository.new(
            timetable_informations: [@timetable_a]
        )

        result = repository.find_all
        result << @timetable_b

        assert_equal [@timetable_a], repository.find_all
    end

    def test_replace_all
        repository = TimetableInformationRepository.new
        repository.replace_all([@timetable_a])

        assert_equal [@timetable_a], repository.find_all
    end

    def test_invalid_initialization_argument
        assert_raises(TypeError) do
            TimetableInformationRepository.new(timetable_informations: 'not an array')
        end
    end

    def test_replace_all_with_empty_array
        repository = TimetableInformationRepository.new(timetable_informations: [@timetable_a])
        repository.replace_all([])

        assert_equal [], repository.find_all
    end

    def test_invalid_replace_all_argument
        repository = TimetableInformationRepository.new

        assert_raises(TypeError) do
            repository.replace_all('not an array')
        end
    end
end
