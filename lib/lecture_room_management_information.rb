require 'date'

class LectureRoomManagementInformation < Data.define(:date, :day_of_the_week, :term, :periods, :room_name, :subject, :user, :comment)
    FULL_LECTURE_ROOM_NAME = '全講義室'
    LECTURE_ROOM_NAME_PATTERN = /\A第([1-9]\d*)講義室\z/

    def initialize(date:, day_of_the_week:, term:, periods:, room_name:, subject:, user:, comment:)
        unless date.is_a?(Date)
            raise TypeError, "date must be a Date object"
        end
        unless day_of_the_week.is_a?(Symbol)
            raise TypeError, "day_of_the_week must be a Symbol"
        end
        unless term.is_a?(Integer)
            raise TypeError, "term must be an Integer"
        end
        unless periods.is_a?(Array) && periods.all? { |p| p.is_a?(Symbol) }
            raise TypeError, "periods must be an Array of Symbols"
        end
        unless room_name.is_a?(String)
            raise TypeError, "room_name must be a String"
        end
        unless subject.is_a?(String)
            raise TypeError, "subject must be a String"
        end
        unless user.is_a?(String)
            raise TypeError, "user must be a String"
        end
        unless comment.is_a?(String)
            raise TypeError, "comment must be a String"
        end

        super(date: date, day_of_the_week: day_of_the_week, term: term, periods: periods.dup, room_name: room_name, subject: subject, user: user, comment: comment) 
    end

    def conflicting_periods_with(lecture_room_management_information:)
        unless lecture_room_management_information.is_a?(LectureRoomManagementInformation)
            raise TypeError, "lecture_room_management_information must be an instance of LectureRoomManagementInformation"
        end

        return [] unless date == lecture_room_management_information.date
        return [] unless self.class.room_names_conflict?(room_name, lecture_room_management_information.room_name)

        periods & lecture_room_management_information.periods
    end

    def self.room_names_conflict?(room_name, other_room_name)
        normalized_room_name = normalize_room_name(room_name)
        normalized_other_room_name = normalize_room_name(other_room_name)

        return true if normalized_room_name == normalized_other_room_name

        full_lecture_room_name?(normalized_room_name) && lecture_room_name?(normalized_other_room_name) ||
            full_lecture_room_name?(normalized_other_room_name) && lecture_room_name?(normalized_room_name)
    end

    def self.lecture_room_name?(room_name)
        normalized_room_name = normalize_room_name(room_name)
        normalized_room_name.is_a?(String) && normalized_room_name.match?(LECTURE_ROOM_NAME_PATTERN)
    end

    def self.full_lecture_room_name?(room_name)
        normalized_room_name = normalize_room_name(room_name)
        normalized_room_name.is_a?(String) && normalized_room_name == FULL_LECTURE_ROOM_NAME
    end

    def self.normalize_room_name(room_name)
        room_name.is_a?(String) ? room_name.unicode_normalize(:nfkc) : room_name
    end

end
