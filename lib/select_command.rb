# frozen_string_literal: true

require_relative "command"
require_relative "excel_data_loader"
require_relative "interactive_menu"
require_relative "lecture_room_management_information_repository"
require_relative "managed_lecture_room_information_repository"
require_relative "managed_lecture_room_parser"

class SelectCommand < Command
  def initialize(
    managed_lecture_room_information_repository,
    lecture_room_management_information_repository,
    interactive_menu
  )
    unless managed_lecture_room_information_repository.is_a?(ManagedLectureRoomInformationRepository)
      raise TypeError,
            "managed_lecture_room_information_repository must be a ManagedLectureRoomInformationRepository"
    end

    unless lecture_room_management_information_repository.is_a?(LectureRoomManagementInformationRepository)
      raise TypeError,
            "lecture_room_management_information_repository must be a LectureRoomManagementInformationRepository"
    end

    unless interactive_menu.is_a?(InteractiveMenu)
      raise TypeError, "interactive_menu must be an InteractiveMenu"
    end

    @managed_lecture_room_information_repository = managed_lecture_room_information_repository
    @lecture_room_management_information_repository = lecture_room_management_information_repository
    @interactive_menu = interactive_menu
  end

  def execute
    begin
      workbook = ExcelDataLoader.load_managed_lecture_room_xlsx_file
    rescue ExcelDataLoader::InvalidExcelFileError
      return CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED)
    rescue Errno::ENOENT
      return CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_FILE_NOT_FOUND)
    rescue Errno::EACCES, Errno::EPERM
      return CommandResult.new(false, false, ErrorHandler::ERROR_FILE_OPERATION_PERMISSION_DENIED)
    end

    if workbook.nil?
      xlsx_files = Dir.glob(File.join("data", "管理対象講義室", "*.xlsx"))
      error_number =
        if xlsx_files.length > 1
          ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED
        else
          ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_FILE_NOT_FOUND
        end

      return CommandResult.new(
        false,
        false,
        error_number
      )
    end

    worksheet = workbook[0]
    parser = ManagedLectureRoomParser.new(worksheet)
    managed_lecture_room_informations = parser.parse_managed_lecture_room_worksheet
    room_names = managed_lecture_room_informations.map(&:room_name)
    has_duplicate_room_name = room_names.uniq.length != room_names.length

    if managed_lecture_room_informations.empty? || has_duplicate_room_name
      return CommandResult.new(
        false,
        false,
        ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED
      )
    end

    puts "管理対象講義室データを読み込みました．"
    puts "----------"
    managed_lecture_room_informations.each do |information|
      puts "- #{information.room_name}"
    end
    puts "----------"

    is_selected = @interactive_menu.ask_yes_or_no(
      "表示されている講義室を管理対象としますか？"
    )
    unless is_selected
      @managed_lecture_room_information_repository.replace_all([])
      @lecture_room_management_information_repository.replace_all([])

      return CommandResult.new(
        false,
        false,
        ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_NOT_SELECTED
      )
    end

    @managed_lecture_room_information_repository.replace_all(
      managed_lecture_room_informations
    )
    @lecture_room_management_information_repository.replace_all([])

    puts "管理対象講義室の設定が完了しました．"
    puts "管理対象講義室の変更に伴い，講義室管理情報をリセットしました．"
    CommandResult.new(false, true, SUCCESS)
  end
end
