class LectureRoomManagementInformationFactory
  def initialize(
    academic_calendar_informations,
    timetable_informations,
    reservation_informations,
    managed_lecture_room_informations,
    term
  )
    unless academic_calendar_informations.is_a?(Array)
      raise TypeError, 'academic_calendar_informations must be a Array.'
    end
    unless timetable_informations.is_a?(Array)
      raise TypeError, 'timetable_informations must be a Array.'
    end
    unless reservation_informations.is_a?(Array)
      raise TypeError, 'reservation_informations must be a Array.'
    end
    unless managed_lecture_room_informations.is_a?(Array)
      raise TypeError, 'managed_lecture_room_informations must be a Array.'
    end
    unless (term.is_a?(Integer) && 1 <= term && term <= 4) || term.nil?
      raise TypeError, 'term must be nil or a Integer (1 ~ 4).'
    end

    @academic_calendar_informations = academic_calendar_informations
    @timetable_informations = timetable_informations
    @reservation_informations = reservation_informations
    @managed_lecture_room_informations = managed_lecture_room_informations
    @term = term
  end

  def create_from_timetable_informations
    lecture_room_management_informations = []

    target_timetable_informations =
      if @term.nil?
        @timetable_informations
      else
        @timetable_informations.select do |timetable_information|
          timetable_information.term == @term
        end
      end

    target_timetable_informations.each do |timetable_information|
      lecture_room_management_informations +=
        create_from_timetable_information(timetable_information)
    end

    return lecture_room_management_informations
  end

  def create_from_reservation_informations
    lecture_room_management_informations = []

    @reservation_informations.each do |reservation_information|
      informations = create_from_reservation_information(reservation_information)

      if informations.nil?
        return nil
      end
      
      if @term != nil
        informations = informations.select do |info|
          info.term == @term
        end
      end

      lecture_room_management_informations += informations
    end

    return lecture_room_management_informations
  end

  def create_from_timetable_information(timetable_information)
    unless timetable_information.is_a?(TimetableInformation)
      raise TypeError, 'timetable_information must be a TimetableInformation.'
    end
    
    filtered_academic_calendar_informations = 
      @academic_calendar_informations.select do |academic_calendar_information|
        effective_day_of_the_week =
          if academic_calendar_information.day_attribute.day_of_the_week_changes != nil
            academic_calendar_information.day_attribute.day_of_the_week_changes
          else
            academic_calendar_information.day_of_the_week
          end

        academic_calendar_information.term == timetable_information.term &&
        academic_calendar_information.day_attribute.is_public_holiday == false &&
        academic_calendar_information.day_attribute.is_holiday == false &&
        academic_calendar_information.day_attribute.is_makeup_class == false &&
        effective_day_of_the_week == timetable_information.day_of_the_week
      end
    
    lecture_room_management_informations = []
    filtered_academic_calendar_informations.each do |information|
      timetable_information.room_names.each do |room_name|
        lecture_room_management_informations.append(
          LectureRoomManagementInformation.new(
            date: information.date,
            day_of_the_week: information.day_of_the_week,
            term: information.term,
            periods: timetable_information.periods,
            room_name: room_name,
            subject: timetable_information.subject,
            user: timetable_information.user,
            comment: information.day_attribute.comments.nil? ? "" : information.day_attribute.comments.join("　")
          )
        )
      end
    end

    return lecture_room_management_informations
  end

  def create_from_reservation_information(reservation_information)
    unless reservation_information.is_a?(ReservationInformation)
      raise TypeError, 'reservation_information must be a ReservationInformation.'
    end

    filtered_academic_calendar_informations =
      @academic_calendar_informations.select do |academic_calendar_information|
        academic_calendar_information.date == reservation_information.date
      end
    
    if filtered_academic_calendar_informations.empty? || filtered_academic_calendar_informations.length > 1
      return nil
    end

    filtered_academic_calendar_information = filtered_academic_calendar_informations.first

    lecture_room_management_informations = []
    reservation_information.room_names.each do |room_name|
      lecture_room_management_informations.append(
        LectureRoomManagementInformation.new(
          date: reservation_information.date,
          day_of_the_week: filtered_academic_calendar_information.day_of_the_week,
          term: filtered_academic_calendar_information.term,
          periods: reservation_information.periods,
          room_name: room_name,
          subject: reservation_information.subject,
          user: reservation_information.user,
          comment: filtered_academic_calendar_information.day_attribute.comments.nil? ? "" : filtered_academic_calendar_information.day_attribute.comments.join("　")
        )
      )
    end
    
    return lecture_room_management_informations
  end
end
