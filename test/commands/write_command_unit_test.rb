require_relative '../test_helper'
require_relative '../../lib/write_command'

class DummyExcelDataExporter < ExcelDataExporter
  attr_reader :calls

  def initialize
    @calls = []
  end

  def export(workbook, file_name)
    @calls << [workbook, file_name]
  end
end

class ErrorRaisingExcelDataExporter < ExcelDataExporter
  def initialize(error)
    @error = error
  end

  def export(_workbook, _file_name)
    raise @error
  end
end

class WriteCommandTest < Minitest::Test
  def test_select_managed_lecture_room_management_informations_expands_full_lecture_room
    full_lecture_room_information = LectureRoomManagementInformation.new(
      date: Date.new(2024, 6, 1),
      day_of_the_week: :sat,
      term: 1,
      periods: [:p1, :p2],
      room_name: '全講義室',
      subject: 'Seminar',
      user: 'Coordinator',
      comment: 'All rooms'
    )
    unrelated_information = LectureRoomManagementInformation.new(
      date: Date.new(2024, 6, 1),
      day_of_the_week: :sat,
      term: 1,
      periods: [:p3],
      room_name: '会議室',
      subject: 'Meeting',
      user: 'Chair',
      comment: 'Unrelated'
    )
    command = WriteCommand.new(
      LectureRoomManagementInformationRepository.new(lecture_room_management_informations: [full_lecture_room_information, unrelated_information]),
      AcademicCalendarInformationRepository.new(academic_calendar_informations: []),
      ManagedLectureRoomInformationRepository.new(
        managed_lecture_room_informations: [
          ManagedLectureRoomInformation.new(room_name: '第１講義室'),
          ManagedLectureRoomInformation.new(room_name: '第100講義室'),
          ManagedLectureRoomInformation.new(room_name: '会議室')
        ]
      ),
      DummyExcelDataExporter.new,
      'dummy'
    )

    selected = command.send(
      :select_managed_lecture_room_management_informations,
      [full_lecture_room_information, unrelated_information],
      command.instance_variable_get(:@managed_lecture_room_information_repository).find_all
    )

    assert_equal ['第１講義室', '第100講義室', '会議室'], selected.map(&:room_name)
    assert_equal [[:p1, :p2], [:p1, :p2], [:p3]], selected.map(&:periods)
  end

  def test_execute_returns_path_error_when_exporter_rejects_output_path
    exporter = ErrorRaisingExcelDataExporter.new(ApplicationPath::InvalidPathError.new)

    result = build_executable_command(exporter).execute

    refute result.is_succeed
    assert_equal ErrorHandler::ERROR_PATH_OUTSIDE_ALLOWED_DIRECTORY, result.error_number
  end

  def test_execute_returns_permission_error_when_exporter_raises_eacces
    exporter = ErrorRaisingExcelDataExporter.new(Errno::EACCES.new)

    result = build_executable_command(exporter).execute

    refute result.is_succeed
    assert_equal ErrorHandler::ERROR_FILE_OPERATION_PERMISSION_DENIED, result.error_number
  end

  def test_execute_returns_permission_error_when_exporter_raises_eperm
    exporter = ErrorRaisingExcelDataExporter.new(Errno::EPERM.new)

    result = build_executable_command(exporter).execute

    refute result.is_succeed
    assert_equal ErrorHandler::ERROR_FILE_OPERATION_PERMISSION_DENIED, result.error_number
  end

  def test_execute_returns_permission_error_when_exporter_raises_erofs
    exporter = ErrorRaisingExcelDataExporter.new(Errno::EROFS.new)

    result = build_executable_command(exporter).execute

    refute result.is_succeed
    assert_equal ErrorHandler::ERROR_FILE_OPERATION_PERMISSION_DENIED, result.error_number
  end

  private

  def build_executable_command(exporter)
    date = Date.new(2024, 6, 3)
    room_name = '第1講義室'
    day_attribute = DayAttribute.new(
      day_of_the_week_changes: nil,
      is_makeup_class: false,
      is_exam_period: false,
      is_public_holiday: false,
      is_holiday: false,
      comments: []
    )
    academic_calendar_information = AcademicCalendarInformation.new(
      date: date,
      day_of_the_week: :mon,
      term: 1,
      day_attribute: day_attribute
    )
    managed_lecture_room_information = ManagedLectureRoomInformation.new(room_name: room_name)
    lecture_room_management_information = LectureRoomManagementInformation.new(
      date: date,
      day_of_the_week: :mon,
      term: 1,
      periods: [:p1],
      room_name: room_name,
      subject: 'Programming',
      user: 'Teacher',
      comment: ''
    )

    WriteCommand.new(
      LectureRoomManagementInformationRepository.new(
        lecture_room_management_informations: [lecture_room_management_information]
      ),
      AcademicCalendarInformationRepository.new(
        academic_calendar_informations: [academic_calendar_information]
      ),
      ManagedLectureRoomInformationRepository.new(
        managed_lecture_room_informations: [managed_lecture_room_information]
      ),
      exporter,
      'test_output'
    )
  end
end
