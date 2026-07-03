require_relative '../test_helper'
require_relative '../../lib/timetable_information'

class TimetableInformationTest < Minitest::Test
    def setup
        @valid_date = Date.new(2024, 6, 1)
        @valid_day_of_the_week = :mon
        @valid_term = 1
        @valid_periods = [:p1, :p2]
        @valid_room_names = ["Room A"]
        @valid_subject = "Mathematics"
        @valid_user = "John Doe"
        @valid_comment = "No comments"
    end

    def test_valid_initialization
        info = TimetableInformation.new(
            subject: @valid_subject,
            term: @valid_term,
            day_of_the_week: @valid_day_of_the_week,
            periods: @valid_periods,
            user: @valid_user,
            room_names: @valid_room_names
        )
        assert_equal @valid_subject, info.subject
        assert_equal @valid_term, info.term
        assert_equal @valid_day_of_the_week, info.day_of_the_week
        assert_equal @valid_periods, info.periods
        assert_equal @valid_user, info.user
        assert_equal @valid_room_names, info.room_names
    end

    def test_valid_empty_periods_and_room_names
        info = TimetableInformation.new(
            subject: '',
            term: 0,
            day_of_the_week: @valid_day_of_the_week,
            periods: [],
            user: '',
            room_names: []
        )

        assert_equal '', info.subject
        assert_equal 0, info.term
        assert_equal [], info.periods
        assert_equal '', info.user
        assert_equal [], info.room_names
    end

    def test_invalid_subject
        assert_raises(TypeError) do
            TimetableInformation.new(
                subject: 123,
                term: @valid_term,
                day_of_the_week: @valid_day_of_the_week,
                periods: @valid_periods,
                user: @valid_user,
                room_names: @valid_room_names
            )
        end
    end

    def test_invalid_term
        assert_raises(TypeError) do
            TimetableInformation.new(
                subject: @valid_subject,
                term: "First Term",
                day_of_the_week: @valid_day_of_the_week,
                periods: @valid_periods,
                user: @valid_user,
                room_names: @valid_room_names
            )
        end
    end

    def test_invalid_day_of_the_week
        assert_raises(TypeError) do
            TimetableInformation.new(
                subject: @valid_subject,
                term: @valid_term,
                day_of_the_week: "Monday",
                periods: @valid_periods,
                user: @valid_user,
                room_names: @valid_room_names
            )
        end
    end

    def test_invalid_periods
        assert_raises(TypeError) do
            TimetableInformation.new(
                subject: @valid_subject,
                term: @valid_term,
                day_of_the_week: @valid_day_of_the_week,
                periods: "first, second",
                user: @valid_user,
                room_names: @valid_room_names
            )
        end
    end

    def test_invalid_user
        assert_raises(TypeError) do
            TimetableInformation.new(
                subject: @valid_subject,
                term: @valid_term,
                day_of_the_week: @valid_day_of_the_week,
                periods: @valid_periods,
                user: 123,
                room_names: @valid_room_names
            )
        end
    end

    def test_invalid_room_names
        assert_raises(TypeError) do
            TimetableInformation.new(
                subject: @valid_subject,
                term: @valid_term,
                day_of_the_week: @valid_day_of_the_week,
                periods: @valid_periods,
                user: @valid_user,
                room_names: 123
            )
        end
    end

    def test_invalid_room_names_contents
        assert_raises(TypeError) do
            TimetableInformation.new(
                subject: @valid_subject,
                term: @valid_term,
                day_of_the_week: @valid_day_of_the_week,
                periods: @valid_periods,
                user: @valid_user,
                room_names: ["Room A", 123]
            )
        end
    end

    def test_array_arguments_are_copied
        periods = [:p1, :p2]
        room_names = ['Room A']

        info = TimetableInformation.new(
            subject: @valid_subject,
            term: @valid_term,
            day_of_the_week: @valid_day_of_the_week,
            periods: periods,
            user: @valid_user,
            room_names: room_names
        )

        periods << :p3
        room_names << 'Room B'

        assert_equal [:p1, :p2], info.periods
        assert_equal ['Room A'], info.room_names
    end
end

    
