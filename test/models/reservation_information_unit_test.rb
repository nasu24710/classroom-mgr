require_relative '../test_helper'
require_relative '../../lib/reservation_information'

class ReservationInformationTest < Minitest::Test
    def setup
        @valid_date = Date.new(2024, 6, 1)
        @valid_subject = "Mathematics"
        @valid_periods = [:p1, :p2]
        @valid_user = "John Doe"
        @valid_room_names = ["Room A"]
    end

    def test_valid_initialization
        info = ReservationInformation.new(
            date: @valid_date,
            subject: @valid_subject,
            periods: @valid_periods,
            user: @valid_user,
            room_names: @valid_room_names
        )
        assert_equal @valid_date, info.date
        assert_equal @valid_subject, info.subject
        assert_equal @valid_periods, info.periods
        assert_equal @valid_user, info.user
        assert_equal @valid_room_names, info.room_names
    end

    def test_valid_empty_periods_and_room_names
        info = ReservationInformation.new(
            date: @valid_date,
            subject: '',
            periods: [],
            user: '',
            room_names: []
        )

        assert_equal '', info.subject
        assert_equal [], info.periods
        assert_equal '', info.user
        assert_equal [], info.room_names
    end

    def test_invalid_date
        assert_raises(TypeError) do
            ReservationInformation.new(
                date: "2024-06-01",
                subject: @valid_subject,
                periods: @valid_periods,
                user: @valid_user,
                room_names: @valid_room_names
            )
        end
    end

    def test_invalid_subject
        assert_raises(TypeError) do
            ReservationInformation.new(
                date: @valid_date,
                subject: 123,
                periods: @valid_periods,
                user: @valid_user,
                room_names: @valid_room_names
            )
        end
    end

    def test_invalid_periods
        assert_raises(TypeError) do
            ReservationInformation.new(
                date: @valid_date,
                subject: @valid_subject,
                periods: "not an array",
                user: @valid_user,
                room_names: @valid_room_names
            )
        end
    end

    def test_invalid_user
        assert_raises(TypeError) do
            ReservationInformation.new(
                date: @valid_date,
                subject: @valid_subject,
                periods: @valid_periods,
                user: 123,
                room_names: @valid_room_names
            )
        end
    end

    def test_invalid_room_names
        assert_raises(TypeError) do
            ReservationInformation.new(
                date: @valid_date,
                subject: @valid_subject,
                periods: @valid_periods,
                user: @valid_user,
                room_names: 123
            )
        end
    end

    def test_invalid_room_names_contents
        assert_raises(TypeError) do
            ReservationInformation.new(
                date: @valid_date,
                subject: @valid_subject,
                periods: @valid_periods,
                user: @valid_user,
                room_names: ["Room A", 123]
            )
        end
    end

    def test_array_arguments_are_copied
        periods = [:p1, :p2]
        room_names = ['Room A']

        info = ReservationInformation.new(
            date: @valid_date,
            subject: @valid_subject,
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

    
