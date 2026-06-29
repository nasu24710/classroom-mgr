require_relative 'lecture_room_management_information'

class LectureRoomManagementInformationRepository
    def initialize(lecture_room_management_informations: [])
        @lecture_room_management_informations = []

        unless lecture_room_management_informations.is_a?(Array)
            raise TypeError, "lecture_room_management_informations must be an Array"
        end

        replace_all(lecture_room_management_informations)
    end

    def add(lecture_room_management_information)
        unless lecture_room_management_information.is_a?(LectureRoomManagementInformation)
            raise TypeError, "lecture_room_management_information must be an instance of LectureRoomManagementInformation"
        end
        
        @lecture_room_management_informations << lecture_room_management_information
    end

    def remove(lecture_room_management_information)
        unless lecture_room_management_information.is_a?(LectureRoomManagementInformation)
            raise TypeError, "lecture_room_management_information must be an instance of LectureRoomManagementInformation"
        end

        @lecture_room_management_informations.delete(lecture_room_management_information)
    end

    def replace_all(lecture_room_management_informations)
        unless lecture_room_management_informations.is_a?(Array)
            raise TypeError, "lecture_room_management_informations must be an Array"
        end

        lecture_room_management_informations.map do |info|
            unless info.is_a?(LectureRoomManagementInformation)
                raise TypeError, "All elements must be instances of LectureRoomManagementInformation"
            end
        end

        @lecture_room_management_informations = lecture_room_management_informations.dup
    end

    def find_all
        @lecture_room_management_informations.dup
    end

    def find_by_date_and_lecture_room_name(date:, lecture_room_name:)
        unless date.is_a?(Date)
            raise TypeError, "date must be a Date object"
        end
        unless lecture_room_name.is_a?(String)
            raise TypeError, "lecture_room_name must be a String"
        end
        
        @lecture_room_management_informations.select do |info|
            info.date == date && info.room_name == lecture_room_name
        end
    end
end
