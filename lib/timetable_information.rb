require 'date'

class TimetableInformation < Data.define(:subject, :term, :day_of_the_week, :periods, :user, :room_names)
    def initialize(subject:, term:, day_of_the_week:, periods:, user:, room_names:)
        unless subject.is_a?(String)
            raise TypeError, "subject must be a String"
        end
        unless term.is_a?(Integer)
            raise TypeError, "term must be an Integer"
        end
        unless day_of_the_week.is_a?(Symbol)
            raise TypeError, "day_of_the_week must be a Symbol"
        end
        unless periods.is_a?(Array) && periods.all? { |p| p.is_a?(Symbol) }
            raise TypeError, "periods must be an Array of Symbols"
        end
        unless user.is_a?(String)
            raise TypeError, "user must be a String"
        end
        unless room_names.is_a?(Array) && room_names.all? { |r| r.is_a?(String) }
            raise TypeError, "room_names must be an Array of Strings"
        end

        super(subject: subject, term: term, day_of_the_week: day_of_the_week, periods: periods.dup, user: user, room_names: room_names.dup)
    end
end
