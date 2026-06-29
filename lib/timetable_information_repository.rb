require_relative 'timetable_information'

class TimetableInformationRepository
    def initialize(timetable_informations: [])
        @timetable_informations = []

        unless timetable_informations.is_a?(Array)
            raise TypeError, "timetable_informations must be an Array"
        end

        replace_all(timetable_informations)
    end

    def replace_all(timetable_informations)
        unless timetable_informations.is_a?(Array)
            raise TypeError, "timetable_informations must be an Array"
        end

        timetable_informations.each do |info|
            unless info.is_a?(TimetableInformation)
                raise TypeError, "All elements must be instances of TimetableInformation"
            end
        end

        @timetable_informations = timetable_informations.dup
    end

    def find_all
        @timetable_informations.dup
    end
end
