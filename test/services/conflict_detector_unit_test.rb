require_relative '../test_helper'
require_relative '../../lib/conflict_detector'

class ConflictDetectorTest < Minitest::Test
    def setup
        @information = LectureRoomManagementInformation.new(
            date: Date.new(2024, 6, 1),
            day_of_the_week: :sat,
            term: 1,
            periods: [:p1, :p2],
            room_name: 'Room A',
            subject: 'Mathematics',
            user: 'John Doe',
            comment: 'First booking'
        )
        @conflicting_information = LectureRoomManagementInformation.new(
            date: Date.new(2024, 6, 1),
            day_of_the_week: :sat,
            term: 1,
            periods: [:p2, :p3],
            room_name: 'Room A',
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Second booking'
        )
        @related_conflicting_information = LectureRoomManagementInformation.new(
            date: Date.new(2024, 6, 1),
            day_of_the_week: :sat,
            term: 1,
            periods: [:p2, :p3],
            room_name: 'Room B',
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Related booking'
        )
        @not_conflicting_information = LectureRoomManagementInformation.new(
            date: Date.new(2024, 6, 1),
            day_of_the_week: :sat,
            term: 1,
            periods: [:p4],
            room_name: 'Room A',
            subject: 'Chemistry',
            user: 'Alice',
            comment: 'Third booking'
        )
        @full_lecture_room_information = LectureRoomManagementInformation.new(
            date: Date.new(2024, 6, 1),
            day_of_the_week: :sat,
            term: 1,
            periods: [:p1, :p2],
            room_name: '全講義室',
            subject: 'Seminar',
            user: 'Coordinator',
            comment: 'All rooms'
        )
        @specific_lecture_room_information = LectureRoomManagementInformation.new(
            date: Date.new(2024, 6, 1),
            day_of_the_week: :sat,
            term: 1,
            periods: [:p2, :p3],
            room_name: '第1講義室',
            subject: 'Workshop',
            user: 'Presenter',
            comment: 'Specific room'
        )
    end

    def test_detect_conflicts
        conflicts = ConflictDetector.detect_conflicts([
            @information,
            @conflicting_information,
            @related_conflicting_information,
            @not_conflicting_information
        ], managed_lecture_room_informations: [
            ManagedLectureRoomInformation.new(room_name: 'Room A')
        ])

        assert_equal 1, conflicts.length
        assert_equal 'Room A', conflicts.first.room_name
        assert_equal Date.new(2024, 6, 1), conflicts.first.date
        assert_equal [:p2], conflicts.first.period
        assert_equal [
            @information,
            @conflicting_information,
            @related_conflicting_information
        ], conflicts.first.conflicting_informations
    end

    def test_detect_conflicts_with_no_conflicts
        assert_equal [], ConflictDetector.detect_conflicts([@information, @not_conflicting_information])
    end

    def test_detect_conflicts_with_empty_array
        assert_equal [], ConflictDetector.detect_conflicts([])
    end

    def test_detect_conflicts_with_empty_managed_rooms
        assert_equal [], ConflictDetector.detect_conflicts([
            @information,
            @conflicting_information
        ], managed_lecture_room_informations: [])
    end

    def test_detect_conflicts_with_different_periods
        different_period_information = LectureRoomManagementInformation.new(
            date: Date.new(2024, 6, 1),
            day_of_the_week: :sat,
            term: 1,
            periods: [:p3, :p4],
            room_name: 'Room A',
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Second booking'
        )

        assert_equal [], ConflictDetector.detect_conflicts([
            @information,
            different_period_information
        ], managed_lecture_room_informations: [
            ManagedLectureRoomInformation.new(room_name: 'Room A')
        ])
    end

    def test_detect_conflicts_with_different_date
        different_date_information = LectureRoomManagementInformation.new(
            date: Date.new(2024, 6, 2),
            day_of_the_week: :sun,
            term: 1,
            periods: [:p2, :p3],
            room_name: 'Room A',
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Second booking'
        )

        assert_equal [], ConflictDetector.detect_conflicts([
            @information,
            different_date_information
        ], managed_lecture_room_informations: [
            ManagedLectureRoomInformation.new(room_name: 'Room A')
        ])
    end

    def test_detect_conflicts_with_same_subject
        same_subject_information = LectureRoomManagementInformation.new(
            date: Date.new(2024, 6, 1),
            day_of_the_week: :sat,
            term: 1,
            periods: [:p2, :p3],
            room_name: 'Room A',
            subject: 'Mathematics',
            user: 'Jane Doe',
            comment: 'Second booking'
        )

        assert_equal [], ConflictDetector.detect_conflicts([@information, same_subject_information])
    end

    def test_detect_conflicts_ignores_unmanaged_room
        conflicts = ConflictDetector.detect_conflicts([
            @information,
            @conflicting_information
        ], managed_lecture_room_informations: [
            ManagedLectureRoomInformation.new(room_name: 'Room B')
        ])

        assert_equal [], conflicts
    end

    def test_detect_conflicts_when_related_information_uses_managed_room
        unmanaged_information = LectureRoomManagementInformation.new(
            date: Date.new(2024, 6, 1),
            day_of_the_week: :sat,
            term: 1,
            periods: [:p1, :p2],
            room_name: 'Room C',
            subject: 'Mathematics',
            user: 'John Doe',
            comment: 'Unmanaged conflicting room'
        )
        unmanaged_conflicting_information = LectureRoomManagementInformation.new(
            date: Date.new(2024, 6, 1),
            day_of_the_week: :sat,
            term: 1,
            periods: [:p2, :p3],
            room_name: 'Room C',
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Unmanaged conflicting room'
        )
        related_managed_information = LectureRoomManagementInformation.new(
            date: Date.new(2024, 6, 1),
            day_of_the_week: :sat,
            term: 1,
            periods: [:p1, :p2],
            room_name: 'Room A',
            subject: 'Mathematics',
            user: 'John Doe',
            comment: 'Related managed room'
        )

        conflicts = ConflictDetector.detect_conflicts([
            unmanaged_information,
            unmanaged_conflicting_information,
            related_managed_information
        ], managed_lecture_room_informations: [
            ManagedLectureRoomInformation.new(room_name: 'Room A')
        ])

        assert_equal 1, conflicts.length
        assert_equal 'Room C', conflicts.first.room_name
        assert_equal [
            unmanaged_information,
            related_managed_information,
            unmanaged_conflicting_information
        ], conflicts.first.conflicting_informations
    end

    def test_detect_conflicts_treats_full_lecture_room_as_conflicting_with_specific_lecture_room
        conflicts = ConflictDetector.detect_conflicts([
            @full_lecture_room_information,
            @specific_lecture_room_information
        ], managed_lecture_room_informations: [
            ManagedLectureRoomInformation.new(room_name: '第1講義室')
        ])

        assert_equal 1, conflicts.length
        assert_equal '全講義室', conflicts.first.room_name
        assert_equal [:p2], conflicts.first.period
        assert_equal [
            @full_lecture_room_information,
            @specific_lecture_room_information
        ], conflicts.first.conflicting_informations
    end

    def test_detect_conflicts_treats_full_width_managed_room_name_as_conflicting_with_specific_lecture_room
        conflicts = ConflictDetector.detect_conflicts([
            @full_lecture_room_information,
            @specific_lecture_room_information
        ], managed_lecture_room_informations: [
            ManagedLectureRoomInformation.new(room_name: '第１講義室')
        ])

        assert_equal 1, conflicts.length
        assert_equal '全講義室', conflicts.first.room_name
        assert_equal [:p2], conflicts.first.period
    end

    def test_invalid_arguments
        assert_raises(TypeError) { ConflictDetector.detect_conflicts('not array') }
        assert_raises(TypeError) { ConflictDetector.detect_conflicts(['not information']) }
        assert_raises(TypeError) do
            ConflictDetector.detect_conflicts([], managed_lecture_room_informations: ['not managed room'])
        end
    end
end
