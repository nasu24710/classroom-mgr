require_relative '../test_helper'
require_relative '../../lib/managed_lecture_room_information'

class ManagedLectureRoomInformationTest < Minitest::Test
    def setup
        @valid_room_name = "Room A"
    end

    def test_valid_initialization
        info = ManagedLectureRoomInformation.new(room_name: @valid_room_name)
        assert_equal @valid_room_name, info.room_name
    end

    def test_valid_empty_room_name
        info = ManagedLectureRoomInformation.new(room_name: '')
        assert_equal '', info.room_name
    end

    def test_invalid_room_name
        assert_raises(TypeError) do
            ManagedLectureRoomInformation.new(room_name: 123)
        end
    end
end

    
