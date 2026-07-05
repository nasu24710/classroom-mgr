# frozen_string_literal: true

require_relative "command"
require_relative "excel_data_loader"
require_relative "interactive_menu"
require_relative "managed_lecture_room_information_repository"
require_relative "managed_lecture_room_parser"

class SelectCommand < Command
  VALID_LECTURE_ROOM_NAMES = [
    "1講",
    "第1講義室",
    "2講",
    "第2講義室",
    "4講",
    "第4講義室",
    "5講",
    "第5講義室",
    "10講",
    "第10講義室",
    "11講",
    "第11講義室",
    "14講",
    "第14講義室",
    "15講",
    "第15講義室",
    "17講",
    "第17講義室",
    "プログラミング演習室1",
    "プログラミング演習室2",
    "環104",
    "環104室",
    "自然大",
    "環101",
    "環101室",
    "303",
    "303室",
    "103",
    "103室",
    "一般B41",
    "一般B41室",
    "一般B33",
    "一般B33室",
    "コモンズ",
    "工大"
  ].freeze

  def initialize(managed_lecture_room_information_repository, interactive_menu)
    unless managed_lecture_room_information_repository.is_a?(ManagedLectureRoomInformationRepository)
      raise TypeError,
            "managed_lecture_room_information_repository must be a ManagedLectureRoomInformationRepository"
    end

    unless interactive_menu.is_a?(InteractiveMenu)
      raise TypeError, "interactive_menu must be an InteractiveMenu"
    end

    @managed_lecture_room_information_repository = managed_lecture_room_information_repository
    @interactive_menu = interactive_menu
  end

  def execute
    workbook = ExcelDataLoader.load_managed_lecture_room_xlsx_file
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
    contains_invalid_name = managed_lecture_room_informations.any? do |information|
      normalized_room_name = information.room_name.unicode_normalize(:nfkc)
      !VALID_LECTURE_ROOM_NAMES.include?(normalized_room_name)
    end

    if managed_lecture_room_informations.empty? || contains_invalid_name
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
      return CommandResult.new(
        false,
        false,
        ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_NOT_SELECTED
      )
    end

    @managed_lecture_room_information_repository.replace_all(
      managed_lecture_room_informations
    )

    puts "管理対象講義室の設定が完了しました．"
    CommandResult.new(false, true, SUCCESS)
  end
end
