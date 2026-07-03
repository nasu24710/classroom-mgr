require 'date'
require_relative 'day_attribute'

class AcademicCalendarInformation < Data.define(:date, :day_of_the_week, :term, :day_attribute)
    def initialize(date:, day_of_the_week:, term:, day_attribute:)
        unless date.is_a?(Date)
            raise TypeError, "date must be a Date object"
        end
        unless day_of_the_week.is_a?(Symbol)
            raise TypeError, "day_of_the_week must be a Symbol"
        end
        unless term.is_a?(Integer)
            raise TypeError, "term must be an Integer"
        end
        unless day_attribute.is_a?(DayAttribute)
            raise TypeError, "day_attribute must be a DayAttribute object"
        end
        super(date: date, day_of_the_week: day_of_the_week, term: term, day_attribute: day_attribute)
    end
end