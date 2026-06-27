class PrintCommand
  def initialize(
    lecture_room_management_information_repository,
    finding_date,
    finding_subject
    )
    unless lecture_room_management_information_repository.is_a?(LectureRoomManagementInformationRepository)
      raise ArgumentError, 'lecture_room_management_information_repository must be a LectureRoomManagementInformationRepository.'
    end

    @lecture_room_management_information_repository = lecture_room_management_information_repository
    @finding_date = finding_date
    @finding_subject = finding_subject
  end

  def execute
    lecture_room_management_informations = @lecture_room_management_information_repository.find_all
    if lecture_room_management_informations.empty?
      return false, false, -1 # ToCheck: CommandResultの返却処理はこの形式で返却してOK？
    end

    if @finding_date != nil
      lecture_room_management_informations = find_by_date(lecture_room_management_informations)
    end
    
    if @finding_subject != nil
      lecture_room_management_informations = find_by_subject(lecture_room_management_informations)
    end

    print_all(lecture_room_management_informations)

    return false, false, 0 # ToCheck: CommandResultの返却処理はこの形式で返却してOK？
  end

  def print_all(lecture_room_management_informations)
    output = LectureRoomManagementInformationFormatter.to_formatted_string(lecture_room_management_informations)
    puts output
  end

  def find_by_subject(lecture_room_management_informations)
    filtered_lecture_room_management_informations = []

    lecture_room_management_informations.each do |lecture_room_management_information|
      if lecture_room_management_information.subject == @finding_subject
        filtered_lecture_room_management_informations.append(lecture_room_management_information)
      end
    end

    return filtered_lecture_room_management_informations
  end

  def find_by_date(lecture_room_management_informations)
    filtered_lecture_room_management_informations = []

    lecture_room_management_informations.each do |lecture_room_management_information|
      if lecture_room_management_information.date.strftime('%m%d') == @finding_date
        filtered_lecture_room_management_informations.append(lecture_room_management_information)
      end
    end

    return filtered_lecture_room_management_informations
  end
end
