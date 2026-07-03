require 'date'

class ReservationInformation < Data.define(:date, :subject, :periods, :user, :room_names)
    def initialize(date:, subject:, periods:, user:, room_names:)
        unless date.is_a?(Date)
            raise TypeError, "date must be a Date object"
        end
        unless subject.is_a?(String)
            raise TypeError, "subject must be a String"
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

        super(date: date, subject: subject, periods: periods.dup, user: user, room_names: room_names.dup)
    end
end
