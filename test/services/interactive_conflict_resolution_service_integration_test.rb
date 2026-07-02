require_relative '../test_helper'
require_relative '../../lib/interactive_conflict_resolution_service'

class IntegrationFakeInteractiveMenu < InteractiveMenu
    attr_reader :options

    def initialize(selected_indexes)
        @selected_indexes = selected_indexes.dup
        @options = []
    end

    def select_from_list(_message, options, header: nil)
        @options << options
        @selected_indexes.shift || 0
    end
end

class InteractiveConflictResolutionServiceIntegrationTest < Minitest::Test
    def test_execute_keeps_selected_subject_and_removes_related_information_for_other_subject
        information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:p1, :p2],
            subject: 'Mathematics',
            user: 'John Doe',
            comment: 'First booking'
        )
        conflicting_information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:p2, :p3],
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Second booking'
        )
        related_conflicting_information = lecture_room_management_information(
            room_name: 'Room B',
            periods: [:p2, :p3],
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Related booking'
        )
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [
                information,
                conflicting_information,
                related_conflicting_information
            ]
        )
        menu = IntegrationFakeInteractiveMenu.new([1])
        service = InteractiveConflictResolutionService.new(repository, menu, managed_repository(['Room A']))

        output = capture_io { service.execute }.first

        assert_equal [conflicting_information, related_conflicting_information], repository.find_all
        assert_equal 1, menu.options.length
        assert_includes output, '講義室の利用に1件の競合が見つかりました．'
        assert_includes output, '--- 競合 1/1 ---'
        assert_includes output, '科目名・予約名「Physics」が選択されました．'
        assert_includes output, '1件の競合を解消しました．'
    end

    def test_execute_ignores_unmanaged_room_conflicts
        information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:p1, :p2],
            subject: 'Mathematics',
            user: 'John Doe',
            comment: 'First booking'
        )
        conflicting_information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:p2, :p3],
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Second booking'
        )
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [information, conflicting_information]
        )
        menu = IntegrationFakeInteractiveMenu.new([1])
        service = InteractiveConflictResolutionService.new(repository, menu, managed_repository(['Room B']))

        output = capture_io { service.execute }.first

        assert_equal [information, conflicting_information], repository.find_all
        assert_equal 0, menu.options.length
        assert_equal '', output
    end

    def test_execute_without_managed_repository_resolves_conflicts
        information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:p1, :p2],
            subject: 'Mathematics',
            user: 'John Doe',
            comment: 'First booking'
        )
        conflicting_information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:p2, :p3],
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Second booking'
        )
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [information, conflicting_information]
        )
        menu = IntegrationFakeInteractiveMenu.new([0])
        service = InteractiveConflictResolutionService.new(repository, menu)

        output = capture_io { service.execute }.first

        assert_equal [information], repository.find_all
        assert_equal 1, menu.options.length
        assert_includes output, '講義室の利用に1件の競合が見つかりました．'
        assert_includes output, '科目名・予約名「Mathematics」が選択されました．'
        assert_includes output, '1件の競合を解消しました．'
    end

    def test_execute_resolves_unmanaged_room_conflict_when_related_information_uses_managed_room
        unmanaged_information = lecture_room_management_information(
            room_name: 'Room C',
            periods: [:p1, :p2],
            subject: 'Mathematics',
            user: 'John Doe',
            comment: 'Unmanaged conflicting room'
        )
        related_managed_information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:p1, :p2],
            subject: 'Mathematics',
            user: 'John Doe',
            comment: 'Related managed room'
        )
        unmanaged_conflicting_information = lecture_room_management_information(
            room_name: 'Room C',
            periods: [:p2, :p3],
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Unmanaged conflicting room'
        )
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [
                unmanaged_information,
                related_managed_information,
                unmanaged_conflicting_information
            ]
        )
        menu = IntegrationFakeInteractiveMenu.new([1])
        service = InteractiveConflictResolutionService.new(repository, menu, managed_repository(['Room A']))

        output = capture_io { service.execute }.first

        assert_equal [unmanaged_conflicting_information], repository.find_all
        assert_equal 1, menu.options.length
        assert_includes output, '講義室の利用に1件の競合が見つかりました．'
        assert_includes output, '科目名・予約名「Physics」が選択されました．'
        assert_includes output, '1件の競合を解消しました．'
    end

    def test_execute_resolves_multiple_conflicts_in_loop
        information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:p1, :p2],
            subject: 'Mathematics',
            user: 'John Doe',
            comment: 'First booking'
        )
        conflicting_information = lecture_room_management_information(
            room_name: 'Room A',
            periods: [:p2, :p3],
            subject: 'Physics',
            user: 'Jane Doe',
            comment: 'Second booking'
        )
        class_c = lecture_room_management_information(
            room_name: 'Room C',
            periods: [:p4],
            subject: 'Chemistry',
            user: 'Alice',
            comment: 'Third booking'
        )
        reservation_d = lecture_room_management_information(
            room_name: 'Room C',
            periods: [:p4, :p5],
            subject: 'Biology',
            user: 'Bob',
            comment: 'Fourth booking'
        )
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [
                information,
                conflicting_information,
                class_c,
                reservation_d
            ]
        )
        menu = IntegrationFakeInteractiveMenu.new([0, 1])
        service = InteractiveConflictResolutionService.new(
            repository,
            menu,
            managed_repository(['Room A', 'Room C'])
        )

        output = capture_io { service.execute }.first

        assert_equal [information, reservation_d], repository.find_all
        assert_equal 2, menu.options.length
        assert_includes output, '講義室の利用に2件の競合が見つかりました．'
        assert_includes output, '--- 競合 1/2 ---'
        assert_includes output, '--- 競合 2/2 ---'
        assert_includes output, '2件の競合を解消しました．'
    end

    def test_execute_counts_initial_conflicts_when_one_resolution_removes_multiple_conflicts
        reservation_a = lecture_room_management_information(
            room_name: 'Room 303',
            periods: [:p1, :p2, :p3, :p4, :p5, :p6, :p7, :p8],
            subject: 'Reservation A',
            user: 'Alice',
            comment: 'All day booking'
        )
        reservation_b = lecture_room_management_information(
            room_name: 'Room 303',
            periods: [:p1],
            subject: 'Reservation B',
            user: 'Bob',
            comment: 'First period booking'
        )
        reservation_c = lecture_room_management_information(
            room_name: 'Room 303',
            periods: [:p2],
            subject: 'Reservation C',
            user: 'Carol',
            comment: 'Second period booking'
        )
        repository = LectureRoomManagementInformationRepository.new(
            lecture_room_management_informations: [
                reservation_a,
                reservation_b,
                reservation_c
            ]
        )
        menu = IntegrationFakeInteractiveMenu.new([1])
        service = InteractiveConflictResolutionService.new(
            repository,
            menu,
            managed_repository(['Room 303'])
        )

        output = capture_io { service.execute }.first

        assert_equal [reservation_b, reservation_c], repository.find_all
        assert_equal 1, menu.options.length
        assert_includes output, '講義室の利用に2件の競合が見つかりました．'
        assert_includes output, '--- 競合 1/2 ---'
        refute_includes output, '--- 競合 2/2 ---'
        assert_includes output, '2件の競合を解消しました．'
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

    def managed_repository(room_names)
        ManagedLectureRoomInformationRepository.new(
            managed_lecture_room_informations: room_names.map do |room_name|
                ManagedLectureRoomInformation.new(room_name: room_name)
            end
        )
    end
end
