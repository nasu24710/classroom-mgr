class ManagedLectureRoomInformationRepository
  def initialize(managed_lecture_room_informations)
    @managed_lecture_room_informations = []

    unless managed_lecture_room_informations.is_a?(Array)
      raise ArgumentError,'managed_lecture_room_informations must be an Array.'
    end  

    replace_all(managed_lecture_room_informations)
  end
  
  def replace_all(managed_lecture_room_informations)
    unless managed_lecture_room_informations.all? {
      |information| information.is_a?(ManagedLectureRoomInformation)
    }
      raise ArgumentError,'All elements must be ManagedLectureRoomInformation.'
    end

    @managed_lecture_room_informations = managed_lecture_room_informations.dup
  end

  def find_all
    return @managed_lecture_room_informations.dup   
  end
end
