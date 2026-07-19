# frozen_string_literal: true

require_relative 'command'
require_relative 'academic_calendar_information_repository'
require_relative 'timetable_information_repository'
require_relative 'reservation_information_repository'
require_relative 'excel_data_loader'
require_relative 'command_result'
require_relative 'academic_calendar_parser'
require_relative 'timetable_parser'
require_relative 'reservation_parser'
require_relative 'error_handler'

class ReadCommand < Command
  def initialize(
    academic_calendar_information_repository,
    timetable_information_repository,
    reservation_information_repository,
    directory_path
  )
    unless academic_calendar_information_repository.is_a?(AcademicCalendarInformationRepository)
      raise TypeError, 'academic_calendar_information_repository must be a AcademicCalendarInformationRepository.'
    end

    unless timetable_information_repository.is_a?(TimetableInformationRepository)
      raise TypeError, 'timetable_information_repository must be a TimetableInformationRepository.'
    end

    unless reservation_information_repository.is_a?(ReservationInformationRepository)
      raise TypeError, 'reservation_information_repository must be a ReservationInformationRepository.'
    end

    unless directory_path.is_a?(String)
      raise TypeError, 'directory_path must be a String.'
    end

    @academic_calendar_information_repository = academic_calendar_information_repository
    @timetable_information_repository = timetable_information_repository
    @reservation_information_repository = reservation_information_repository
    @directory_path = directory_path
  end

  def execute
    if @directory_path.nil? || @directory_path.empty?
      return CommandResult.new(false, false, ErrorHandler::ERROR_DIRECTORY_NOT_SPECIFIED)
    end

    # 利用者入力をアプリケーションルートのdata直下へ安全に解決する。
    begin
      directory_path = ApplicationPath.read_directory(@directory_path)
    rescue Errno::EACCES, Errno::EPERM
      return CommandResult.new(false, false, ErrorHandler::ERROR_FILE_OPERATION_PERMISSION_DENIED)
    rescue ApplicationPath::InvalidPathError
      return CommandResult.new(false, false, ErrorHandler::ERROR_PATH_OUTSIDE_ALLOWED_DIRECTORY)
    end

    #######################################
    # 学年暦情報の取得                    
    #######################################    
    begin
      academic_calendar_workbook = ExcelDataLoader.load_academic_calendar_xlsx_file(directory_path)
    rescue ExcelDataLoader::MultipleExcelFilesError
      return CommandResult.new(false, false, ErrorHandler::ERROR_MULTIPLE_EXCEL_FILES)
    rescue ExcelDataLoader::InvalidExcelFileError
      return CommandResult.new(false, false, ErrorHandler::ERROR_ACADEMIC_CALENDAR_PARSE_FAILED)
    rescue Errno::ENOENT
      return CommandResult.new(false, false, ErrorHandler::ERROR_ACADEMIC_CALENDAR_FILE_NOT_FOUND)
    rescue Errno::EACCES, Errno::EPERM
      return CommandResult.new(false, false, ErrorHandler::ERROR_FILE_OPERATION_PERMISSION_DENIED)
    rescue ApplicationPath::InvalidPathError
      return CommandResult.new(false, false, ErrorHandler::ERROR_PATH_OUTSIDE_ALLOWED_DIRECTORY)
    end

    if academic_calendar_workbook.nil?
      return CommandResult.new(false, false, ErrorHandler::ERROR_ACADEMIC_CALENDAR_FILE_NOT_FOUND)
    end

    academic_calendar_parser = AcademicCalendarParser.new(academic_calendar_workbook[0], academic_calendar_workbook.stylesheet)
    academic_calendar_informations = academic_calendar_parser.parse_academic_calendar_worksheet

    if academic_calendar_informations.empty?
      return CommandResult.new(false, false, ErrorHandler::ERROR_ACADEMIC_CALENDAR_PARSE_FAILED)
    end

    #######################################
    # 時間割情報の取得
    #######################################
    begin
      timetable_workbook = ExcelDataLoader.load_timetable_xlsx_file(directory_path)
    rescue ExcelDataLoader::MultipleExcelFilesError
      return CommandResult.new(false, false, ErrorHandler::ERROR_MULTIPLE_EXCEL_FILES)
    rescue ExcelDataLoader::InvalidExcelFileError
      return CommandResult.new(false, false, ErrorHandler::ERROR_TIMETABLE_PARSE_FAILED)
    rescue Errno::ENOENT
      return CommandResult.new(false, false, ErrorHandler::ERROR_TIMETABLE_FILE_NOT_FOUND)
    rescue Errno::EACCES, Errno::EPERM
      return CommandResult.new(false, false, ErrorHandler::ERROR_FILE_OPERATION_PERMISSION_DENIED)
    rescue ApplicationPath::InvalidPathError
      return CommandResult.new(false, false, ErrorHandler::ERROR_PATH_OUTSIDE_ALLOWED_DIRECTORY)
    end

    if timetable_workbook.nil?
      return CommandResult.new(false, false, ErrorHandler::ERROR_TIMETABLE_FILE_NOT_FOUND)
    end

    timetable_parser = TimetableParser.new(timetable_workbook[0])
    timetable_informations = timetable_parser.parse_timetable_worksheet

    if timetable_informations.empty?
      return CommandResult.new(false, false, ErrorHandler::ERROR_TIMETABLE_PARSE_FAILED)
    end

    #######################################
    # 予約情報の取得
    #######################################
    begin
      reservation_workbook = ExcelDataLoader.load_reservation_xlsx_file(directory_path)
    rescue ExcelDataLoader::MultipleExcelFilesError
      return CommandResult.new(false, false, ErrorHandler::ERROR_MULTIPLE_EXCEL_FILES)
    rescue ExcelDataLoader::InvalidExcelFileError
      return CommandResult.new(false, false, ErrorHandler::ERROR_RESERVATION_PARSE_FAILED)
    rescue Errno::ENOENT
      return CommandResult.new(false, false, ErrorHandler::ERROR_RESERVATION_FILE_NOT_FOUND)
    rescue Errno::EACCES, Errno::EPERM
      return CommandResult.new(false, false, ErrorHandler::ERROR_FILE_OPERATION_PERMISSION_DENIED)
    rescue ApplicationPath::InvalidPathError
      return CommandResult.new(false, false, ErrorHandler::ERROR_PATH_OUTSIDE_ALLOWED_DIRECTORY)
    end

    if reservation_workbook.nil?
      return CommandResult.new(false, false, ErrorHandler::ERROR_RESERVATION_FILE_NOT_FOUND)
    end

    reservation_parser = ReservationParser.new(reservation_workbook[0])
    reservation_informations = reservation_parser.parse_reservation_worksheet

    if reservation_informations.empty?
      return CommandResult.new(false, false, ErrorHandler::ERROR_RESERVATION_PARSE_FAILED)
    end

    ########################################
    # repository への保存
    ########################################
    @academic_calendar_information_repository.replace_all(academic_calendar_informations)
    @timetable_information_repository.replace_all(timetable_informations)
    @reservation_information_repository.replace_all(reservation_informations)

    ########################################
    # 成功時の処理
    ########################################
    academic_calendar_filename = File.basename(Dir.glob(File.join(directory_path, '学年暦', '*.xlsx')).first.to_s)
    timetable_filename = File.basename(Dir.glob(File.join(directory_path, '時間割', '*.xlsx')).first.to_s)
    reservation_filename = File.basename(Dir.glob(File.join(directory_path, '予約', '*.xlsx')).first.to_s)

    message = <<~TEXT
      入力データの読み込みが完了しました．
      学年暦データ ： #{academic_calendar_filename}
      時間割データ ： #{timetable_filename}
      予約データ   ： #{reservation_filename}
    TEXT

    puts message

    return CommandResult.new(false, true, 0)
  end
end
