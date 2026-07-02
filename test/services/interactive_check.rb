# frozen_string_literal: true

require 'date'

begin
  require_relative '../../lib/interactive_conflict_resolution_service'
rescue LoadError
  require './lib/interactive_conflict_resolution_service'
end

def build_information(
  room_name:,
  periods:,
  subject:,
  user:,
  comment:,
  date: Date.new(2024, 6, 12),
  day_of_the_week: :fri
)
  LectureRoomManagementInformation.new(
    date: date,
    day_of_the_week: day_of_the_week,
    term: 1,
    periods: periods,
    room_name: room_name,
    subject: subject,
    user: user,
    comment: comment
  )
end

def print_informations(title, informations)
  puts title
  if informations.empty?
    puts '  (none)'
  else
    informations.each_with_index do |information, index|
      puts [
        "  #{index + 1}.",
        information.date.to_s,
        information.room_name,
        information.periods.join(', '),
        information.subject,
        information.user,
        information.comment
      ].join(' / ')
    end
  end
  puts
end

repository = LectureRoomManagementInformationRepository.new(
  lecture_room_management_informations: [
    build_information(
      room_name: '第1講義室',
      periods: [:p7, :p8],
      subject: '情報化における職業1',
      user: '山内',
      comment: ''
    ),
    build_information(
      room_name: '第11講義室',
      periods: [:p7, :p8],
      subject: '情報化における職業1',
      user: '山内',
      comment: ''
    ),
    build_information(
      room_name: '第1講義室',
      periods: [:p7, :p8],
      subject: '工・第3年次編入学試験_準備',
      user: '学務課工学部担当',
      comment: ''
    ),
    build_information(
      room_name: '第10講義室',
      periods: [:p7, :p8],
      subject: '工・第3年次編入学試験_準備',
      user: '学務課工学部担当',
      comment: ''
    ),
    build_information(
      room_name: 'Room 303',
      periods: [:p1, :p2],
      subject: 'Mathematics',
      user: 'John Doe',
      comment: 'Class across rooms'
    ),
    build_information(
      room_name: 'Room 304',
      periods: [:p1, :p2],
      subject: 'Mathematics',
      user: 'John Doe',
      comment: 'Class across rooms'
    ),
    build_information(
      room_name: 'Room 303',
      periods: [:p2, :p3],
      subject: 'Physics Reservation',
      user: 'Jane Doe',
      comment: 'Reservation across rooms'
    ),
    build_information(
      room_name: 'Room 305',
      periods: [:p2, :p3],
      subject: 'Physics Reservation',
      user: 'Jane Doe',
      comment: 'Reservation across rooms'
    ),
    build_information(
      room_name: 'Room 404',
      periods: [:p4],
      subject: 'Chemistry',
      user: 'Alice',
      comment: 'Managed room conflict'
    ),
    build_information(
      room_name: 'Room 404',
      periods: [:p4, :p5],
      subject: 'Biology Reservation',
      user: 'Bob',
      comment: 'Managed room conflict'
    ),
    build_information(
      room_name: 'Room 505',
      periods: [:p6],
      subject: 'History',
      user: 'Carol',
      comment: 'Unmanaged conflict candidate'
    ),
    build_information(
      room_name: 'Room 505',
      periods: [:p6],
      subject: 'English Reservation',
      user: 'Dan',
      comment: 'Ignored because unmanaged'
    ),
    build_information(
      room_name: 'Room 606',
      periods: [:p3],
      subject: 'Same Subject Seminar',
      user: 'Ellen',
      comment: 'Same subject is not a conflict'
    ),
    build_information(
      room_name: 'Room 606',
      periods: [:p3, :p4],
      subject: 'Same Subject Seminar',
      user: 'Ellen',
      comment: 'Same subject is not a conflict'
    )
  ]
)

managed_repository = ManagedLectureRoomInformationRepository.new(
  managed_lecture_room_informations: [
    ManagedLectureRoomInformation.new(room_name: '第1講義室'),
    ManagedLectureRoomInformation.new(room_name: 'Room 303'),
    ManagedLectureRoomInformation.new(room_name: 'Room 404'),
    ManagedLectureRoomInformation.new(room_name: 'Room 606')
  ]
)

service = InteractiveConflictResolutionService.new(
  repository,
  InteractiveMenu.new,
  managed_repository
)

puts 'InteractiveConflictResolutionService interactive check'
puts
puts '管理対象講義室:'
managed_repository.find_all.each do |information|
  puts "  - #{information.room_name}"
end
puts
print_informations('実行前の講義室管理情報:', repository.find_all)

service.execute

puts
print_informations('実行後の講義室管理情報:', repository.find_all)
