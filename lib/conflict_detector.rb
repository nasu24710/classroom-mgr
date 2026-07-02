require_relative 'conflict'
require_relative 'managed_lecture_room_information'

class ConflictDetector
    def self.detect_conflicts(lecture_room_management_informations, managed_lecture_room_informations: nil)
        new.detect_conflicts(
            lecture_room_management_informations,
            managed_lecture_room_informations: managed_lecture_room_informations
        )
    end

    def detect_conflicts(lecture_room_management_informations, managed_lecture_room_informations: nil)
        unless lecture_room_management_informations.is_a?(Array)
            raise TypeError, "lecture_room_management_informations must be an Array"
        end
        unless lecture_room_management_informations.all? { |info| info.is_a?(LectureRoomManagementInformation) }
            raise TypeError, "All elements must be instances of LectureRoomManagementInformation"
        end
        unless managed_lecture_room_informations.nil? ||
               managed_lecture_room_informations.is_a?(Array) &&
               managed_lecture_room_informations.all? { |info| info.is_a?(ManagedLectureRoomInformation) }
            raise TypeError, "managed_lecture_room_informations must be an Array of ManagedLectureRoomInformation"
        end

        conflicts = []
        managed_room_names = managed_lecture_room_informations&.map(&:room_name)

        lecture_room_management_informations.combination(2) do |information, other_information|
            conflicting_periods = information.conflicting_periods_with(
                lecture_room_management_information: other_information
            )
            next if conflicting_periods.empty?
            next if information.subject == other_information.subject
            conflicting_informations = related_informations(
                lecture_room_management_informations,
                information
            ) + related_informations(
                lecture_room_management_informations,
                other_information
            )
            next unless managed_room_names.nil? || includes_managed_room?(conflicting_informations, managed_room_names)

            conflicts << Conflict.new(
                room_name: information.room_name,
                date: information.date,
                period: conflicting_periods,
                conflicting_informations: conflicting_informations.uniq
            )
        end

        conflicts
    end

    private

    def includes_managed_room?(lecture_room_management_informations, managed_room_names)
        lecture_room_management_informations.any? do |information|
            managed_room_names.include?(information.room_name)
        end
    end

    def related_informations(lecture_room_management_informations, lecture_room_management_information)
        lecture_room_management_informations.select do |information|
            information.date == lecture_room_management_information.date &&
                information.subject == lecture_room_management_information.subject
        end
    end
end
