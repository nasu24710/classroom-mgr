require_relative '../test_helper'
require_relative '../../lib/conflict'

class ConflictTest < Minitest::Test
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
    end

    def test_valid_initialization
        conflict = Conflict.new(
            room_name: 'Room A',
            date: Date.new(2024, 6, 1),
            period: [:p2],
            conflicting_informations: [@information]
        )

        assert_equal 'Room A', conflict.room_name
        assert_equal Date.new(2024, 6, 1), conflict.date
        assert_equal [:p2], conflict.period
        assert_equal [:p2], conflict.periods
        assert_equal [@information], conflict.conflicting_informations
    end

    def test_invalid_arguments
        assert_raises(TypeError) do
            Conflict.new(room_name: 123, date: Date.new(2024, 6, 1), period: [:p1], conflicting_informations: [@information])
        end

        assert_raises(TypeError) do
            Conflict.new(room_name: 'Room A', date: '2024-06-01', period: [:p1], conflicting_informations: [@information])
        end

        assert_raises(TypeError) do
            Conflict.new(room_name: 'Room A', date: Date.new(2024, 6, 1), period: ['p1'], conflicting_informations: [@information])
        end

        assert_raises(TypeError) do
            Conflict.new(room_name: 'Room A', date: Date.new(2024, 6, 1), period: :p1, conflicting_informations: [@information])
        end

        assert_raises(TypeError) do
            Conflict.new(room_name: 'Room A', date: Date.new(2024, 6, 1), period: [:p1], conflicting_informations: 'not array')
        end

        assert_raises(TypeError) do
            Conflict.new(room_name: 'Room A', date: Date.new(2024, 6, 1), period: [:p1], conflicting_informations: ['not information'])
        end
    end
end
