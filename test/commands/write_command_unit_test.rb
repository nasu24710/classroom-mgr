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
end
