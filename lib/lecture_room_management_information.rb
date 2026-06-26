require 'date'

class LectureRoomManagementInformation < Data.define(:date, :day_of_the_week, :term, :periods, :room_name, :subject, :user, :comment)
    def initialize(date:, day_of_the_week:, term:, periods:, room_name:, subject:, user:, comment:)
        unless date.is_a?(Date)
            raise ArgumentError, "date must be a Date object"
        end
        unless day_of_the_week.is_a?(Symbol)
            raise ArgumentError, "day_of_the_week must be a Symbol"
        end
        unless term.is_a?(Integer)
            raise ArgumentError, "term must be an Integer"
        end
        unless periods.is_a?(Array) && periods.all? { |p| p.is_a?(Symbol) }
            raise ArgumentError, "periods must be an Array of Symbols"
        end
        unless room_name.is_a?(String)
            raise ArgumentError, "room_name must be a String"
        end
        unless subject.is_a?(String)
            raise ArgumentError, "subject must be a String"
        end
        unless user.is_a?(String)
            raise ArgumentError, "user must be a String"
        end
        unless comment.is_a?(String)
            raise ArgumentError, "comment must be a String"
        end

        super(date: date, day_of_the_week: day_of_the_week, term: term, periods: periods.dup, room_name: room_name, subject: subject, user: user, comment: comment) 
    end

    def conflicting_periods_with(lecture_room_management_information:)
        unless lecture_room_management_information.is_a?(LectureRoomManagementInformation)
            raise ArgumentError, "lecture_room_management_information must be an instance of LectureRoomManagementInformation"
        end

        return [] unless date == lecture_room_management_information.date
        return [] unless room_name == lecture_room_management_information.room_name

        periods & lecture_room_management_information.periods
    end

end
