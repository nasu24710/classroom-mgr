require 'date'
require_relative 'lecture_room_management_information'

class Conflict < Data.define(:room_name, :date, :period, :conflicting_informations)
    def initialize(room_name:, date:, period:, conflicting_informations:)
        unless room_name.is_a?(String)
            raise TypeError, "room_name must be a String"
        end
        unless date.is_a?(Date)
            raise TypeError, "date must be a Date object"
        end
        unless period.is_a?(Array) && period.all? { |p| p.is_a?(Symbol) }
            raise TypeError, "period must be an Array of Symbols"
        end
        unless conflicting_informations.is_a?(Array) &&
               conflicting_informations.all? { |info| info.is_a?(LectureRoomManagementInformation) }
            raise TypeError, "conflicting_informations must be an Array of LectureRoomManagementInformation"
        end

        super(
            room_name: room_name,
            date: date,
            period: period.dup,
            conflicting_informations: conflicting_informations.dup
        )
    end

    def periods
        period
    end
end
