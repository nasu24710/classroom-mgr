require 'date'

require_relative "command"
require_relative 'lecture_room_management_information_formatter'
require_relative 'period_master'
require_relative 'academic_year_converter'
require_relative 'error_handler'

class PrintCommand < Command
  def initialize(
    lecture_room_management_information_repository,
    finding_date,
    finding_subject
    )
    unless lecture_room_management_information_repository.is_a?(LectureRoomManagementInformationRepository)
      raise TypeError, 'lecture_room_management_information_repository must be a LectureRoomManagementInformationRepository.'
    end
    unless finding_date.is_a?(String) || finding_date.nil?
      raise TypeError, 'finding_date must be a String.'
    end
    unless finding_subject.is_a?(String) || finding_subject.nil?
      raise TypeError, 'finding_subject must be a String.'
    end

    @lecture_room_management_information_repository = lecture_room_management_information_repository
    @finding_date = finding_date
    @finding_subject = finding_subject
  end

  def execute
    lecture_room_management_informations = @lecture_room_management_information_repository.find_all
    if lecture_room_management_informations.empty?
      return CommandResult.new(false, false, 16)
    end

    # @finding_date のフォーマットチェックと、学年暦の範囲内かどうかのチェック
    # その上で，講義室管理情報を @finding_date でフィルタリングする．
    if @finding_date != nil
      if @finding_date.match?(/\A\d{4}\z/) == false
        return CommandResult.new(false, false, ErrorHandler::ERROR_INVALID_DATE_FORMAT)
      end

      # 講義室管理情報の年度を計算する．
      academic_year =
        AcademicYearConverter.date_to_academic_year(
          lecture_room_management_informations.first.date
        )

      # @finding_date の月日を取得し，年を学年暦の年度に基づいて計算する．
      month = @finding_date[0, 2].to_i
      day = @finding_date[2, 2].to_i
      calendar_year = month >= 4 ? academic_year : academic_year + 1

      # finding_date が有効な日付かどうかをチェックする．
      if Date.valid_date?(calendar_year, month, day) == false
        return CommandResult.new(false, false, ErrorHandler::ERROR_INVALID_DATE_FORMAT)
      end

      lecture_room_management_informations = find_by_date(lecture_room_management_informations)
    end
    
    # 講義室管理情報を @finding_subject でフィルタリングする．
    if @finding_subject != nil
      lecture_room_management_informations = find_by_subject(lecture_room_management_informations)
    end

    print_all(lecture_room_management_informations)

    return CommandResult.new(false, true, 0)
  end

  def print_all(lecture_room_management_informations)
    sorted_lecture_room_management_informations =
      lecture_room_management_informations.sort_by do |lecture_room_management_information|
        if lecture_room_management_information.periods.empty?
          raise ArgumentError, 'periods must not be empty.'
        end

        [
          lecture_room_management_information.date,
          PeriodMaster::ORDER[lecture_room_management_information.periods.first]
        ]
      end

    output = LectureRoomManagementInformationFormatter.to_formatted_string(sorted_lecture_room_management_informations)
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
