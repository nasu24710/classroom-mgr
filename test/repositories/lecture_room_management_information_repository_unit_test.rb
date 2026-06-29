require_relative '../test_helper'
require_relative '../../lib/lecture_room_management_information_repository'
require_relative '../../lib/lecture_room_management_information'

class LectureRoomManagementInformationRepositoryTest < Minitest::Test
    def setup
        @info_a = LectureRoomManagementInformation.new(
            date: Date.new(2024, 6, 1),
            day_of_the_week: :sat,
            term: 1,
            periods: [:p1, :p2],
            room_name: 'Room A',
            subject: 'Mathematics',
            user: 'John Doe',
            comment: 'First booking'
        )

        @info_b = LectureRoomManagementInformation.new(
            date: Date.new(2024, 6, 1),
            day_of_the_week: :sat,
            term: 1,
            periods: [:p2, :p3],
            room_name: 'Room B',
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Second booking'
        )
    end

    def test_initialize_and_find_all
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [@info_a]
        )

        assert_equal [@info_a], repository.find_all
    end

    def test_find_all_returns_copy
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [@info_a]
        )

        result = repository.find_all
        result << @info_b

        assert_equal [@info_a], repository.find_all
    end

    def test_add_remove_and_replace_all
        repository = LectureRoomManagementInformationRepository.new
        repository.add(@info_a)
        repository.add(@info_b)
        assert_equal [@info_a, @info_b], repository.find_all

        repository.remove(@info_a)
        assert_equal [@info_b], repository.find_all

        repository.replace_all([@info_a])
        assert_equal [@info_a], repository.find_all
    end

    def test_find_by_date_and_lecture_room_name
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [@info_a, @info_b]
        )

        assert_equal [@info_a], repository.find_by_date_and_lecture_room_name(
            date: Date.new(2024, 6, 1),
            lecture_room_name: 'Room A'
        )
    end

    def test_find_by_date_and_lecture_room_name_with_multiple_matches
        another_info = LectureRoomManagementInformation.new(
            date: Date.new(2024, 6, 1),
            day_of_the_week: :sat,
            term: 1,
            periods: [:p4],
            room_name: 'Room A',
            subject: 'Chemistry',
            user: 'Alice',
            comment: 'Third booking'
        )

        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [@info_a, @info_b, another_info]
        )

        assert_equal [@info_a, another_info], repository.find_by_date_and_lecture_room_name(
            date: Date.new(2024, 6, 1),
            lecture_room_name: 'Room A'
        )
    end

    def test_find_by_date_and_lecture_room_name_with_no_matches
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [@info_a, @info_b]
        )

        assert_equal [], repository.find_by_date_and_lecture_room_name(
            date: Date.new(2024, 6, 2),
            lecture_room_name: 'Room C'
        )
    end

    def test_invalid_find_by_date_and_lecture_room_name_arguments
        repository = LectureRoomManagementInformationRepository.new

        assert_raises(TypeError) do
            repository.find_by_date_and_lecture_room_name(date: '2024-06-01', lecture_room_name: 'Room A')
        end

        assert_raises(TypeError) do
            repository.find_by_date_and_lecture_room_name(date: Date.new(2024, 6, 1), lecture_room_name: 123)
        end
    end

    def test_invalid_initialization_argument
        assert_raises(TypeError) do
            LectureRoomManagementInformationRepository.new(lecture_room_management_informations: 'not an array')
        end
    end

    def test_invalid_add_and_remove_arguments
        repository = LectureRoomManagementInformationRepository.new

        assert_raises(TypeError) { repository.add('not lecture room management info') }
        assert_raises(TypeError) { repository.remove('not lecture room management info') }
    end

    def test_replace_all_with_empty_array
        repository = LectureRoomManagementInformationRepository.new(lecture_room_management_informations: [@info_a])
        repository.replace_all([])

        assert_equal [], repository.find_all
    end

    def test_invalid_replace_all_argument
        repository = LectureRoomManagementInformationRepository.new

        assert_raises(TypeError) do
            repository.replace_all('not an array')
        end
    end
end
