require_relative 'academic_calendar_information'

class AcademicCalendarInformationRepository
    def initialize(academic_calendar_informations: [])
        @academic_calendar_informations = []

        unless academic_calendar_informations.is_a?(Array)
            raise TypeError, "academic_calendar_informations must be an Array"
        end

        replace_all(academic_calendar_informations)
    end

    def replace_all(academic_calendar_informations)
        unless academic_calendar_informations.is_a?(Array)
            raise TypeError, "academic_calendar_informations must be an Array"
        end

        academic_calendar_informations.map do |info|
            unless info.is_a?(AcademicCalendarInformation)
                raise TypeError, "All elements must be instances of AcademicCalendarInformation"
            end
        end

        @academic_calendar_informations = academic_calendar_informations.dup
    end

    def find_all
        @academic_calendar_informations.dup
    end

    def find_by_day_of_the_week(day_of_the_week)
        unless day_of_the_week.is_a?(Symbol)
            raise TypeError, "day_of_the_week must be a Symbol"
        end

        @academic_calendar_informations.select do |info|
            if info.day_attribute.day_of_the_week_changes.nil?
                info.day_of_the_week == day_of_the_week
            else
                info.day_attribute.day_of_the_week_changes == day_of_the_week
            end
        end
    end
end
