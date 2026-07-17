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
        service = InteractiveConflictResolutionService.new(repository, menu, managed_repository)

        assert_instance_of InteractiveConflictResolutionService, service
    end

    def test_execute_keeps_full_lecture_room_information_after_resolving_conflicts
        full_lecture_room_information = lecture_room_management_information(
            room_name: '全講義室',
            periods: [:p1, :p2],
            subject: 'Seminar',
            user: 'Coordinator',
            comment: 'All rooms'
        )
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [full_lecture_room_information]
        )
        menu = FakeInteractiveMenu.new(0)
        service = InteractiveConflictResolutionService.new(
            repository,
            menu,
            managed_repository(['第１講義室', '第100講義室', '会議室'])
        )

        output = capture_io { service.execute }.first

        assert_equal 1, repository.find_all.length
        assert_equal ['全講義室'], repository.find_all.map(&:room_name)
        assert_equal [:p1, :p2], repository.find_all.first.periods
        assert_equal '', output
    end

    def test_execute_detects_conflicts_before_clearing_full_lecture_room_information
        full_lecture_room_information = lecture_room_management_information(
            room_name: '全講義室',
            periods: [:p1, :p2],
            subject: 'Seminar',
            user: 'Coordinator',
            comment: 'All rooms'
        )
        specific_lecture_room_information = lecture_room_management_information(
            room_name: '第1講義室',
            periods: [:p2, :p3],
            subject: 'Workshop',
            user: 'Presenter',
            comment: 'Specific room'
        )
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [
                full_lecture_room_information,
                specific_lecture_room_information
            ]
        )
        menu = FakeInteractiveMenu.new(0)
        service = InteractiveConflictResolutionService.new(
            repository,
            menu,
            managed_repository(['第1講義室', '第100講義室', '会議室'])
        )

        output = capture_io { service.execute }.first

        assert_includes output, '講義室： 全講義室'
        assert_includes output, '科目名・予約名「Seminar」が選択されました．'
        assert_equal ['全講義室'], repository.find_all.map(&:room_name)
    end

    def test_invalid_initialization_arguments
        repository = LectureRoomManagementInformationRepository.new
        menu = FakeInteractiveMenu.new(0)

        assert_raises(TypeError) { InteractiveConflictResolutionService.new('not repository', menu, managed_repository) }
        assert_raises(TypeError) { InteractiveConflictResolutionService.new(repository, 'not menu', managed_repository) }
        assert_raises(TypeError) { InteractiveConflictResolutionService.new(repository, menu, nil) }
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
        service = InteractiveConflictResolutionService.new(repository, menu, managed_repository)
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
        service = InteractiveConflictResolutionService.new(repository, menu, managed_repository)

        assert_raises(TypeError) { service.resolve_conflict('not conflict') }
    end

    def test_resolve_conflict_rejects_negative_selected_index
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [@information, @conflicting_information]
        )
        menu = FakeInteractiveMenu.new(-1)
        service = InteractiveConflictResolutionService.new(repository, menu, managed_repository)
        conflict = Conflict.new(
            room_name: 'Room A',
            date: Date.new(2024, 6, 1),
            period: [:p2],
            conflicting_informations: [@information, @conflicting_information]
        )

        assert_raises(RangeError) { capture_io { service.resolve_conflict(conflict) } }
        assert_equal [@information, @conflicting_information], repository.find_all
    end

    def test_resolve_conflict_rejects_out_of_range_selected_index
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [@information, @conflicting_information]
        )
        menu = FakeInteractiveMenu.new(2)
        service = InteractiveConflictResolutionService.new(repository, menu, managed_repository)
        conflict = Conflict.new(
            room_name: 'Room A',
            date: Date.new(2024, 6, 1),
            period: [:p2],
            conflicting_informations: [@information, @conflicting_information]
        )

        assert_raises(RangeError) { capture_io { service.resolve_conflict(conflict) } }
        assert_equal [@information, @conflicting_information], repository.find_all
    end

    def test_resolve_conflict_displays_lunch_period
        information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:lunch],
            subject: 'Mathematics',
            user: 'John Doe',
            comment: 'Lunch booking'
        )
        conflicting_information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:lunch],
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Lunch reservation'
        )
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [information, conflicting_information]
        )
        menu = FakeInteractiveMenu.new(0)
        service = InteractiveConflictResolutionService.new(repository, menu, managed_repository)
        conflict = Conflict.new(
            room_name: 'Room A',
            date: Date.new(2024, 6, 1),
            period: [:lunch],
            conflicting_informations: [information, conflicting_information]
        )

        output = capture_io { service.resolve_conflict(conflict) }.first

        assert_includes output, '昼休み'
        refute_includes output, '0限'
        refute_includes output, '昼休み限'
    end

    def test_resolve_conflict_displays_lunch_between_fourth_and_fifth_periods_as_range
        information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:p4, :lunch, :p5],
            subject: 'Mathematics',
            user: 'John Doe',
            comment: 'First booking'
        )
        conflicting_information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:p4, :lunch, :p5],
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Second booking'
        )
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [information, conflicting_information]
        )
        menu = FakeInteractiveMenu.new(0)
        service = InteractiveConflictResolutionService.new(repository, menu, managed_repository)
        conflict = Conflict.new(
            room_name: 'Room A',
            date: Date.new(2024, 6, 1),
            period: [:p4, :lunch, :p5],
            conflicting_informations: [information, conflicting_information]
        )

        output = capture_io { service.resolve_conflict(conflict) }.first

        assert_includes output, '4-5限'
        refute_includes output, '4限，昼休み，5限'
    end

    def test_resolve_conflict_displays_nonconsecutive_periods_separately
        information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:p1, :p3],
            subject: 'Mathematics',
            user: 'John Doe',
            comment: 'First booking'
        )
        conflicting_information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:p1, :p3],
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Second booking'
        )
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [information, conflicting_information]
        )
        menu = FakeInteractiveMenu.new(0)
        service = InteractiveConflictResolutionService.new(repository, menu, managed_repository)
        conflict = Conflict.new(
            room_name: 'Room A',
            date: Date.new(2024, 6, 1),
            period: [:p1, :p3],
            conflicting_informations: [information, conflicting_information]
        )

        output = capture_io { service.resolve_conflict(conflict) }.first

        assert_includes output, '1限，3限'
        refute_includes output, '1-3限'
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

    def managed_repository(room_names = [])
        ManagedLectureRoomInformationRepository.new(
            managed_lecture_room_informations: room_names.map do |room_name|
                ManagedLectureRoomInformation.new(room_name: room_name)
            end
        )
    end
end
