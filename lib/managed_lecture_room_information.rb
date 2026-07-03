class ManagedLectureRoomInformation < Data.define(:room_name)
    def initialize(room_name:)
        unless room_name.is_a?(String)
            raise TypeError, "room_name must be a String"
        end

        super(room_name: room_name)
    end
end
