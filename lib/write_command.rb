require_relative 'academic_calendar_information_repository'
require_relative 'command_result'
require_relative "error_handler"
require_relative 'excel_data_exporter'
require_relative 'lecture_room_management_information'
require_relative 'lecture_room_management_table_builder'
require_relative 'lecture_room_management_table_populator'
require_relative 'lecture_room_management_information_repository'
require_relative 'managed_lecture_room_information_repository'

class WriteCommand
    def initialize(lecture_room_management_information_repository,academic_calendar_information_repository,managed_lecture_room_information_repository,excel_data_exporter,file_name)
      unless lecture_room_management_information_repository.is_a?(LectureRoomManagementInformationRepository)
        raise TypeError, 'lecture_room_management_information_repository must be a LectureRoomManagementInformationRepository.'
      end

      unless academic_calendar_information_repository.is_a?(AcademicCalendarInformationRepository)
        raise TypeError, 'academic_calendar_information_repository must be a AcademicCalendarInformationRepository.'
      end

      unless managed_lecture_room_information_repository.is_a?(ManagedLectureRoomInformationRepository)
        raise TypeError, 'managed_lecture_room_information_repository must be a ManagedLectureRoomInformationRepository.'
      end

      unless excel_data_exporter.is_a?(ExcelDataExporter)
        raise TypeError, 'excel_data_exporter must be an ExcelDataExporter.'
      end

      unless file_name.is_a?(String)
        raise TypeError, 'file_name must be a String.'
      end

      @lecture_room_management_information_repository = lecture_room_management_information_repository

      @academic_calendar_information_repository = academic_calendar_information_repository

      @managed_lecture_room_information_repository = managed_lecture_room_information_repository

      @excel_data_exporter = excel_data_exporter

      @file_name = file_name

    end

    def execute
      academic_calendar_information_list = @academic_calendar_information_repository.find_all
      
      if academic_calendar_information_list.size == 0
        return CommandResult.new(false,false,ErrorHandler::ERROR_ACADEMIC_CALENDAR_NOT_LOADED)
      end

      file_name = @file_name

      if file_name.empty?
        return CommandResult.new(false,false,ErrorHandler::ERROR_OUTPUT_FILE_NOT_SPECIFIED)
      end

      if file_name.match?(/[.\\\/:*?"<>|]/)
        return CommandResult.new(false,false,ErrorHandler::ERROR_INVALID_FILENAME_CHARACTER)
      end
      
      if file_name.length > 256
        return CommandResult.new(false,false,ErrorHandler::ERROR_FILENAME_TOO_LONG)
      end

      managed_lecture_room_information_list = @managed_lecture_room_information_repository.find_all

      lecture_room_management_information_list = select_managed_lecture_room_management_informations(
        @lecture_room_management_information_repository.find_all,
        managed_lecture_room_information_list
      )

      if lecture_room_management_information_list.size == 0
        return CommandResult.new(false,false,ErrorHandler::ERROR_LECTURE_ROOM_MANAGEMENT_INFORMATION_NOT_FOUND)
      end

      table_builder = LectureRoomManagementTableBuilder.new

      builder_result = table_builder.build(academic_calendar_information_list,managed_lecture_room_information_list)

      table_populator = LectureRoomManagementTablePopulator.new(builder_result)

      lecture_room_management_workbook = table_populator.populate_entries(lecture_room_management_information_list)

      @excel_data_exporter.export(lecture_room_management_workbook,file_name)

      puts "講義室管理一覧表の作成が完了しました．"
      puts "出力先： output/#{@file_name}.xlsx"
      return CommandResult.new(false,true,0)
    end
  
    private

    def select_managed_lecture_room_management_informations(
      lecture_room_management_information_list,
      managed_lecture_room_information_list
    )
      managed_room_names = managed_lecture_room_information_list.map do |information|
        [information.room_name, normalize_room_name(information.room_name)]
      end

      lecture_room_management_information_list.flat_map do |information|
        if LectureRoomManagementInformation.full_lecture_room_name?(information.room_name)
          expand_full_lecture_room_information(information, managed_room_names)
        else
          [information]
        end
      end.select do |information|
        managed_room_names.any? do |_, normalized_room_name|
          normalized_room_name == normalize_room_name(information.room_name)
        end
      end
    end

    def expand_full_lecture_room_information(lecture_room_management_information, managed_room_names)
      managed_room_names.filter_map do |original_room_name, normalized_room_name|
        next unless LectureRoomManagementInformation.lecture_room_name?(normalized_room_name)

        LectureRoomManagementInformation.new(
          date: lecture_room_management_information.date,
          day_of_the_week: lecture_room_management_information.day_of_the_week,
          term: lecture_room_management_information.term,
          periods: lecture_room_management_information.periods,
          room_name: original_room_name,
          subject: lecture_room_management_information.subject,
          user: lecture_room_management_information.user,
          comment: lecture_room_management_information.comment
        )
      end
    end

    def normalize_room_name(room_name)
      room_name.unicode_normalize(:nfkc)
    end
end
