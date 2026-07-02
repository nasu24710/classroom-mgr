require_relative '../test_helper'
require_relative '../../lib/interactive_conflict_resolution_service'

class FakeInteractiveMenu < InteractiveMenu
    attr_reader :messages, :options, :headers

    def initialize(selected_index)
        @selected_index = selected_index
        @messages = []
        @options = []
        @headers = []
    end

    def select_from_list(message, options, header: nil)
        @messages << message
        @options << options
        @headers << header
        @selected_index
    end
end

class InteractiveConflictResolutionServiceTest < Minitest::Test
    def setup
        @information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:p1, :p2],
            subject: 'Mathematics',
            user: 'John Doe',
            comment: 'First booking'
        )
        @conflicting_information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:p2, :p3],
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Second booking'
        )
        @related_conflicting_information = lecture_room_management_information(
            room_name: 'Room B',
            periods: [:p2, :p3],
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Related booking'
        )
    end

    def test_valid_initialization
        repository = LectureRoomManagementInformationRepository.new
        menu = FakeInteractiveMenu.new(0)
        service = InteractiveConflictResolutionService.new(repository, menu)

        assert_instance_of InteractiveConflictResolutionService, service
    end

    def test_invalid_initialization_arguments
        repository = LectureRoomManagementInformationRepository.new
        menu = FakeInteractiveMenu.new(0)

        assert_raises(TypeError) { InteractiveConflictResolutionService.new('not repository', menu) }
        assert_raises(TypeError) { InteractiveConflictResolutionService.new(repository, 'not menu') }
        assert_raises(TypeError) { InteractiveConflictResolutionService.new(repository, menu, 'not managed repository') }
    end

    def test_resolve_conflict_groups_options_by_subject_and_removes_non_prioritized_subject
        extra_related_information = lecture_room_management_information(
            room_name: 'Room C',
            periods: [:p4],
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Extra related booking'
        )
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [
                @information,
                @conflicting_information,
                @related_conflicting_information,
                extra_related_information
            ]
        )
        menu = FakeInteractiveMenu.new(0)
        service = InteractiveConflictResolutionService.new(repository, menu)
        conflict = Conflict.new(
            room_name: 'Room A',
            date: Date.new(2024, 6, 1),
            period: [:p2],
            conflicting_informations: [
                @information,
                @conflicting_information,
                @related_conflicting_information
            ]
        )

        output = capture_io { service.resolve_conflict(conflict) }.first

        assert_equal [@information], repository.find_all
        assert_includes output, '日時'
        assert_includes output, '講義室'
        assert_includes output, '科目名・予約名「Mathematics」が選択されました．'
        assert_equal '候補一覧：優先する情報を1つ選択してください．', menu.messages.first
        assert_match(/\A科目名・予約名\s+担当者・予約者\s+備考\s*\z/, menu.headers.first)
        assert_equal 1, menu.options.length
        assert_equal 2, menu.options.first.length
        assert_match(/\AMathematics\s+John Doe\s+First booking\s*\z/, menu.options.first[0])
        assert_match(/\APhysics\s+Jane Doe\s+Second booking\s*\z/, menu.options.first[1])
    end

    def test_resolve_conflict_invalid_argument
        repository = LectureRoomManagementInformationRepository.new
        menu = FakeInteractiveMenu.new(0)
        service = InteractiveConflictResolutionService.new(repository, menu)

        assert_raises(TypeError) { service.resolve_conflict('not conflict') }
    end

    private

    def lecture_room_management_information(room_name:, periods:, subject:, user:, comment:, date: Date.new(2024, 6, 1))
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
end
