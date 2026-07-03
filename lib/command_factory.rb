# frozen_string_literal: true

require_relative "command"
require_relative "read_command"
require_relative "select_command"
require_relative "create_command"
require_relative "print_command"
require_relative "write_command"
require_relative "quit_command"

class CommandFactory
  def initialize(
    lecture_room_management_information_repository = nil,
    academic_calendar_information_repository = nil,
    timetable_information_repository = nil,
    reservation_information_repository = nil,
    managed_lecture_room_information_repository = nil,
    interactive_menu = nil,
    excel_data_exporter = nil
  )
    # 他担当のクラスが読み込まれている場合だけ型を確認する。
    # 未実装の依存先がある段階でも，コマンド系単体で動作確認できるようにしている。
    if !lecture_room_management_information_repository.nil? &&
       Object.const_defined?("LectureRoomManagementInformationRepository") &&
       !lecture_room_management_information_repository.is_a?(Object.const_get("LectureRoomManagementInformationRepository"))
      raise TypeError, "lecture_room_management_information_repository must be a LectureRoomManagementInformationRepository"
    end

    if !academic_calendar_information_repository.nil? &&
       Object.const_defined?("AcademicCalendarInformationRepository") &&
       !academic_calendar_information_repository.is_a?(Object.const_get("AcademicCalendarInformationRepository"))
      raise TypeError, "academic_calendar_information_repository must be an AcademicCalendarInformationRepository"
    end

    if !timetable_information_repository.nil? &&
       Object.const_defined?("TimetableInformationRepository") &&
       !timetable_information_repository.is_a?(Object.const_get("TimetableInformationRepository"))
      raise TypeError, "timetable_information_repository must be a TimetableInformationRepository"
    end

    if !reservation_information_repository.nil? &&
       Object.const_defined?("ReservationInformationRepository") &&
       !reservation_information_repository.is_a?(Object.const_get("ReservationInformationRepository"))
      raise TypeError, "reservation_information_repository must be a ReservationInformationRepository"
    end

    if !managed_lecture_room_information_repository.nil? &&
       Object.const_defined?("ManagedLectureRoomInformationRepository") &&
       !managed_lecture_room_information_repository.is_a?(Object.const_get("ManagedLectureRoomInformationRepository"))
      raise TypeError, "managed_lecture_room_information_repository must be a ManagedLectureRoomInformationRepository"
    end

    if !interactive_menu.nil? &&
       Object.const_defined?("InteractiveMenu") &&
       !interactive_menu.is_a?(Object.const_get("InteractiveMenu"))
      raise TypeError, "interactive_menu must be an InteractiveMenu"
    end

    if !excel_data_exporter.nil? &&
       Object.const_defined?("ExcelDataExporter") &&
       !excel_data_exporter.is_a?(Object.const_get("ExcelDataExporter"))
      raise TypeError, "excel_data_exporter must be an ExcelDataExporter"
    end

    # 各コマンド生成時に渡す共有オブジェクトを保持する。
    @lecture_room_management_information_repository = lecture_room_management_information_repository
    @academic_calendar_information_repository = academic_calendar_information_repository
    @timetable_information_repository = timetable_information_repository
    @reservation_information_repository = reservation_information_repository
    @managed_lecture_room_information_repository = managed_lecture_room_information_repository
    @interactive_menu = interactive_menu
    @excel_data_exporter = excel_data_exporter
  end

  def create(command_name, arguments = [], options = {})
    # コマンド名・引数・オプションは，ここで基本的な型だけ確認する。
    raise TypeError, "command_name must be a String" unless command_name.is_a?(String)
    raise TypeError, "arguments must be an Array" unless arguments.is_a?(Array)
    raise TypeError, "options must be a Hash" unless options.is_a?(Hash)

    # create -t の学期指定は整数として扱う。変換できない値は指定なしとして扱う。
    term = options[:term] || options["term"]
    begin
      term = Integer(term) unless term.nil?
    rescue ArgumentError, TypeError
      term = nil
    end
    finding_date = options[:finding_date] || options["finding_date"] || options[:date] || options["date"]
    finding_subject = options[:finding_subject] || options["finding_subject"] || options[:subject] || options["subject"]

    # 入力されたコマンド名に応じて，対応するコマンドオブジェクトを生成する。
    case command_name.downcase
    when "read"
      ReadCommand.new(
        @academic_calendar_information_repository,
        @timetable_information_repository,
        @reservation_information_repository,
        arguments[0].to_s
      )
    when "select"
      SelectCommand.new(@managed_lecture_room_information_repository, @interactive_menu)
    when "create"
      CreateCommand.new(
        @lecture_room_management_information_repository,
        @academic_calendar_information_repository,
        @timetable_information_repository,
        @reservation_information_repository,
        @managed_lecture_room_information_repository,
        @interactive_menu,
        term
      )
    when "print"
      PrintCommand.new(
        @lecture_room_management_information_repository,
        finding_date&.to_s,
        finding_subject&.to_s
      )
    when "write"
      WriteCommand.new(
        @lecture_room_management_information_repository,
        @academic_calendar_information_repository,
        @excel_data_exporter,
        arguments[0].to_s
      )
    when "quit"
      QuitCommand.new
    else
      nil
    end
  end
end
