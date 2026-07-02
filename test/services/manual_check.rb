# frozen_string_literal: true

require 'date'
require 'stringio'

begin
  require_relative '../../lib/interactive_conflict_resolution_service'
rescue LoadError
  require './lib/interactive_conflict_resolution_service'
end

class RecordingInteractiveMenu < InteractiveMenu
  attr_reader :calls

  def initialize(selected_indexes)
    @selected_indexes = selected_indexes.dup
    @calls = []
  end

  def select_from_list(message, options, header: nil)
    selected_index = @selected_indexes.shift || 0
    @calls << {
      message: message,
      options: options,
      header: header,
      selected_index: selected_index
    }
    selected_index
  end
end

def build_information(
  room_name:,
  periods:,
  subject:,
  user:,
  comment:,
  date: Date.new(2024, 6, 1)
)
  LectureRoomManagementInformation.new(
    date: date,
    day_of_the_week: :sat,
    term: 1,
    periods: periods,
    room_name: room_name,
    subject: subject,
    user: user,
    comment: comment
  )
end

def managed_repository(room_names)
  ManagedLectureRoomInformationRepository.new(
    managed_lecture_room_informations: room_names.map do |room_name|
      ManagedLectureRoomInformation.new(room_name: room_name)
    end
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

def print_menu_calls(menu)
  puts 'Menu output:'
  if menu.calls.empty?
    puts '  (not shown)'
  else
    menu.calls.each_with_index do |call, call_index|
      puts "  Menu #{call_index + 1}: #{call[:message]}"
      puts "    #{call[:header]}" unless call[:header].nil?
      call[:options].each_with_index do |option, option_index|
        marker = option_index == call[:selected_index] ? '*' : ' '
        puts "    #{marker} #{option_index}: #{option}"
      end
      puts "    selected_index: #{call[:selected_index]}"
    end
  end
  puts
end

def print_conflicts(title, repository, managed_repository)
  conflicts = ConflictDetector.detect_conflicts(
    repository.find_all,
    managed_lecture_room_informations: managed_repository.find_all
  )

  puts title
  if conflicts.empty?
    puts '  (none)'
  else
    conflicts.each_with_index do |conflict, index|
      subjects = conflict.conflicting_informations.map(&:subject).uniq.join(' / ')
      rooms = conflict.conflicting_informations.map(&:room_name).join(', ')
      puts [
        "  #{index + 1}.",
        conflict.date.to_s,
        conflict.room_name,
        conflict.period.join(', '),
        subjects,
        "related rooms: #{rooms}"
      ].join(' / ')
    end
  end
  puts
end

def capture_stdout
  original_stdout = $stdout
  captured_stdout = StringIO.new
  $stdout = captured_stdout
  yield
  captured_stdout.string
ensure
  $stdout = original_stdout
end

def run_case(title:, managed_room_names:, informations:, selected_indexes:)
  repository = LectureRoomManagementInformationRepository.new(
    lecture_room_management_informations: informations
  )
  managed_repository = managed_repository(managed_room_names)
  menu = RecordingInteractiveMenu.new(selected_indexes)
  service = InteractiveConflictResolutionService.new(repository, menu, managed_repository)

  puts '=' * 80
  puts title
  puts '=' * 80
  puts
  puts "Input managed rooms: #{managed_room_names.join(', ')}"
  puts "Input selected indexes: #{selected_indexes.join(', ')}"
  puts
  print_informations('Input repository:', repository.find_all)
  print_conflicts('Detected conflicts before execute:', repository, managed_repository)

  service_output = capture_stdout { service.execute }

  print_menu_calls(menu)
  puts 'Service stdout:'
  puts service_output.empty? ? '  (none)' : service_output.lines.map { |line| "  #{line}" }.join
  puts
  print_informations('Output repository:', repository.find_all)
  print_conflicts('Detected conflicts after execute:', repository, managed_repository)
end

puts 'InteractiveConflictResolutionService I/O manual check'
puts

run_case(
  title: '1. Prioritize reservation B, remove all class A related rooms',
  managed_room_names: ['Room A'],
  selected_indexes: [1],
  informations: [
    build_information(
      room_name: 'Room A',
      periods: [:p1, :p2],
      subject: 'Mathematics',
      user: 'John Doe',
      comment: 'First booking'
    ),
    build_information(
      room_name: 'Room A',
      periods: [:p2, :p3],
      subject: 'Physics',
      user: 'Jane Doe',
      comment: 'Second booking'
    ),
    build_information(
      room_name: 'Room B',
      periods: [:p2, :p3],
      subject: 'Physics',
      user: 'Jane Doe',
      comment: 'Related booking'
    )
  ]
)

run_case(
  title: '2. Unmanaged room conflict candidate is ignored',
  managed_room_names: ['Room B'],
  selected_indexes: [0],
  informations: [
    build_information(
      room_name: 'Room A',
      periods: [:p1, :p2],
      subject: 'Mathematics',
      user: 'John Doe',
      comment: 'First booking'
    ),
    build_information(
      room_name: 'Room A',
      periods: [:p2, :p3],
      subject: 'Physics',
      user: 'Jane Doe',
      comment: 'Second booking'
    )
  ]
)

run_case(
  title: '3. Multiple conflicts are resolved in a loop',
  managed_room_names: ['Room A', 'Room C'],
  selected_indexes: [0, 1],
  informations: [
    build_information(
      room_name: 'Room A',
      periods: [:p1, :p2],
      subject: 'Mathematics',
      user: 'John Doe',
      comment: 'First booking'
    ),
    build_information(
      room_name: 'Room A',
      periods: [:p2, :p3],
      subject: 'Physics',
      user: 'Jane Doe',
      comment: 'Second booking'
    ),
    build_information(
      room_name: 'Room C',
      periods: [:p4],
      subject: 'Chemistry',
      user: 'Alice',
      comment: 'Third booking'
    ),
    build_information(
      room_name: 'Room C',
      periods: [:p4, :p5],
      subject: 'Biology',
      user: 'Bob',
      comment: 'Fourth booking'
    )
  ]
)

run_case(
  title: '4. Unmanaged conflict room is handled when related information uses a managed room',
  managed_room_names: ['Room A'],
  selected_indexes: [1],
  informations: [
    build_information(
      room_name: 'Room C',
      periods: [:p1, :p2],
      subject: 'Mathematics',
      user: 'John Doe',
      comment: 'Unmanaged conflicting room'
    ),
    build_information(
      room_name: 'Room A',
      periods: [:p1, :p2],
      subject: 'Mathematics',
      user: 'John Doe',
      comment: 'Related managed room'
    ),
    build_information(
      room_name: 'Room C',
      periods: [:p2, :p3],
      subject: 'Physics',
      user: 'Jane Doe',
      comment: 'Unmanaged conflicting room'
    )
  ]
)
