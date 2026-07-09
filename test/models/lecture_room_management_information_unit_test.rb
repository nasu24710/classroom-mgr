require_relative '../test_helper'
require_relative '../../lib/lecture_room_management_information'

class LectureRoomManagementInformationTest < Minitest::Test
    def setup
        @valid_date = Date.new(2024, 6, 1)
        @valid_day_of_the_week = :mon
        @valid_term = 1
        @valid_periods = [:p1, :p2]
        @valid_room_name = "Room A"
        @valid_subject = "Mathematics"
        @valid_user = "John Doe"
        @valid_comment = "No comments"
        @valid_info = LectureRoomManagementInformation.new(
            date: @valid_date,
            day_of_the_week: @valid_day_of_the_week,
            term: @valid_term,
            periods: @valid_periods,
            room_name: @valid_room_name,
            subject: @valid_subject,
            user: @valid_user,
            comment: @valid_comment
        )
    end

    def test_valid_initialization
        assert_equal @valid_date, @valid_info.date
        assert_equal @valid_day_of_the_week, @valid_info.day_of_the_week
        assert_equal @valid_term, @valid_info.term
        assert_equal @valid_periods, @valid_info.periods
        assert_equal @valid_room_name, @valid_info.room_name
        assert_equal @valid_subject, @valid_info.subject
        assert_equal @valid_user, @valid_info.user
        assert_equal @valid_comment, @valid_info.comment
    end

    def test_valid_empty_periods_and_empty_comment
        info = LectureRoomManagementInformation.new(
            date: @valid_date,
            day_of_the_week: @valid_day_of_the_week,
            term: @valid_term,
            periods: [],
            room_name: @valid_room_name,
            subject: @valid_subject,
            user: @valid_user,
            comment: ''
        )

        assert_equal [], info.periods
        assert_equal '', info.comment
    end

    def test_invalid_date
        assert_raises(TypeError) do
            LectureRoomManagementInformation.new(
                date: "2024-06-01",
                day_of_the_week: @valid_day_of_the_week,
                term: @valid_term,
                periods: @valid_periods,
                room_name: @valid_room_name,
                subject: @valid_subject,
                user: @valid_user,
                comment: @valid_comment
            )
        end
    end

    def test_invalid_day_of_the_week
        assert_raises(TypeError) do
            LectureRoomManagementInformation.new(
                date: @valid_date,
                day_of_the_week: "Monday",
                term: @valid_term,
                periods: @valid_periods,
                room_name: @valid_room_name,
                subject: @valid_subject,
                user: @valid_user,
                comment: @valid_comment
            )
        end
    end

    def test_invalid_term
        assert_raises(TypeError) do
            LectureRoomManagementInformation.new(
                date: @valid_date,
                day_of_the_week: @valid_day_of_the_week,
                term: "First Term",
                periods: @valid_periods,
                room_name: @valid_room_name,
                subject: @valid_subject,
                user: @valid_user,
                comment: @valid_comment
            )
        end
    end

    def test_invalid_periods
        assert_raises(TypeError) do
            LectureRoomManagementInformation.new(
                date: @valid_date,
                day_of_the_week: @valid_day_of_the_week,
                term: @valid_term,
                periods: [:p1, "p2"],
                room_name: @valid_room_name,
                subject: @valid_subject,
                user: @valid_user,
                comment: @valid_comment
            )
        end
    end

    def test_invalid_room_name
        assert_raises(TypeError) do
            LectureRoomManagementInformation.new(
                date: @valid_date,
                day_of_the_week: @valid_day_of_the_week,
                term: @valid_term,
                periods: @valid_periods,
                room_name: 123,
                subject: @valid_subject,
                user: @valid_user,
                comment: @valid_comment
            )
        end
    end

    def test_invalid_subject
        assert_raises(TypeError) do
            LectureRoomManagementInformation.new(
                date: @valid_date,
                day_of_the_week: @valid_day_of_the_week,
                term: @valid_term,
                periods: @valid_periods,
                room_name: @valid_room_name,
                subject: 123,
                user: @valid_user,
                comment: @valid_comment
            )
        end
    end

    def test_invalid_user
        assert_raises(TypeError) do
            LectureRoomManagementInformation.new(
                date: @valid_date,
                day_of_the_week: @valid_day_of_the_week,
                term: @valid_term,
                periods: @valid_periods,
                room_name: @valid_room_name,
                subject: @valid_subject,
                user: 123,
                comment: @valid_comment
            )
        end
    end

    def test_invalid_comment
        assert_raises(TypeError) do
            LectureRoomManagementInformation.new(
                date: @valid_date,
                day_of_the_week: @valid_day_of_the_week,
                term: @valid_term,
                periods: @valid_periods,
                room_name: @valid_room_name,
                subject: @valid_subject,
                user: @valid_user,
                comment: 123
            )
        end
    end

    def test_conflicting_periods_with_overlap
        other = LectureRoomManagementInformation.new(
            date: @valid_date,
            day_of_the_week: @valid_day_of_the_week,
            term: @valid_term,
            periods: [:p2, :p3],
            room_name: @valid_room_name,
            subject: @valid_subject,
            user: @valid_user,
            comment: @valid_comment
        )

        assert_equal [:p2], @valid_info.conflicting_periods_with(lecture_room_management_information: other)
    end

    def test_conflicting_periods_with_no_overlap
        other = LectureRoomManagementInformation.new(
            date: @valid_date,
            day_of_the_week: @valid_day_of_the_week,
            term: @valid_term,
            periods: [:p3, :p4],
            room_name: @valid_room_name,
            subject: @valid_subject,
            user: @valid_user,
            comment: @valid_comment
        )

        assert_equal [], @valid_info.conflicting_periods_with(lecture_room_management_information: other)
    end

    def test_conflicting_periods_with_different_date
        other = LectureRoomManagementInformation.new(
            date: Date.new(2024, 6, 2),
            day_of_the_week: @valid_day_of_the_week,
            term: @valid_term,
            periods: [:p2, :p3],
            room_name: @valid_room_name,
            subject: @valid_subject,
            user: @valid_user,
            comment: @valid_comment
        )

        assert_equal [], @valid_info.conflicting_periods_with(lecture_room_management_information: other)
    end

    def test_conflicting_periods_with_different_room_name
        other = LectureRoomManagementInformation.new(
            date: @valid_date,
            day_of_the_week: @valid_day_of_the_week,
            term: @valid_term,
            periods: [:p2, :p3],
            room_name: "Room B",
            subject: @valid_subject,
            user: @valid_user,
            comment: @valid_comment
        )

        assert_equal [], @valid_info.conflicting_periods_with(lecture_room_management_information: other)
    end

    def test_lecture_room_name_predicate_accepts_only_positive_integers
        assert LectureRoomManagementInformation.lecture_room_name?('第1講義室')
        assert LectureRoomManagementInformation.lecture_room_name?('第１講義室')
        assert LectureRoomManagementInformation.lecture_room_name?('第100講義室')
        refute LectureRoomManagementInformation.lecture_room_name?('第01講義室')
        refute LectureRoomManagementInformation.lecture_room_name?('第0講義室')
        refute LectureRoomManagementInformation.lecture_room_name?('第講義室')
        refute LectureRoomManagementInformation.lecture_room_name?('第一講義室')
        refute LectureRoomManagementInformation.lecture_room_name?('全講義室')
    end

    def test_conflicting_periods_with_full_lecture_room_name
        lecture_room = LectureRoomManagementInformation.new(
            date: @valid_date,
            day_of_the_week: @valid_day_of_the_week,
            term: @valid_term,
            periods: [:p2, :p3],
            room_name: '第1講義室',
            subject: @valid_subject,
            user: @valid_user,
            comment: @valid_comment
        )
        full_lecture_room = LectureRoomManagementInformation.new(
            date: @valid_date,
            day_of_the_week: @valid_day_of_the_week,
            term: @valid_term,
            periods: [:p2, :p4],
            room_name: '全講義室',
            subject: @valid_subject,
            user: @valid_user,
            comment: @valid_comment
        )

        assert_equal [:p2], lecture_room.conflicting_periods_with(lecture_room_management_information: full_lecture_room)
        assert_equal [:p2], full_lecture_room.conflicting_periods_with(lecture_room_management_information: lecture_room)
    end

    def test_conflicting_periods_with_identical_periods
        other = LectureRoomManagementInformation.new(
            date: @valid_date,
            day_of_the_week: @valid_day_of_the_week,
            term: @valid_term,
            periods: @valid_periods.dup,
            room_name: @valid_room_name,
            subject: @valid_subject,
            user: @valid_user,
            comment: @valid_comment
        )

        assert_equal @valid_periods, @valid_info.conflicting_periods_with(lecture_room_management_information: other)
    end

    def test_conflicting_periods_with_invalid_argument
        assert_raises(TypeError) do
            @valid_info.conflicting_periods_with(lecture_room_management_information: "not info")
        end
    end
end
