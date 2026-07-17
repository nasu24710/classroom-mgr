require_relative 'conflict'
require_relative 'conflict_detector'
require_relative 'interactive_menu'
require_relative 'lecture_room_management_information'
require_relative 'lecture_room_management_information_repository'
require_relative 'managed_lecture_room_information_repository'
require_relative 'period_master'

class InteractiveConflictResolutionService
    WEEKDAY_LABELS = %w[日 月 火 水 木 金 土]

    def initialize(
        lecture_room_management_information_repository,
        interactive_menu,
        managed_lecture_room_information_repository
    )
        unless lecture_room_management_information_repository.is_a?(LectureRoomManagementInformationRepository)
            raise TypeError, "lecture_room_management_information_repository must be a LectureRoomManagementInformationRepository"
        end
        unless interactive_menu.is_a?(InteractiveMenu)
            raise TypeError, "interactive_menu must be an InteractiveMenu"
        end
        unless managed_lecture_room_information_repository.is_a?(ManagedLectureRoomInformationRepository)
            raise TypeError, "managed_lecture_room_information_repository must be a ManagedLectureRoomInformationRepository"
        end

        @lecture_room_management_information_repository = lecture_room_management_information_repository
        @interactive_menu = interactive_menu
        @managed_lecture_room_information_repository = managed_lecture_room_information_repository
    end

    def execute
        resolved_conflict_count = 0
        managed_lecture_room_information_list = managed_lecture_room_informations
        lecture_room_management_informations = @lecture_room_management_information_repository.find_all
        conflicts = ConflictDetector.detect_conflicts(
            lecture_room_management_informations,
            managed_lecture_room_informations: managed_lecture_room_information_list
        )
        initial_conflict_count = conflicts.length

        if initial_conflict_count.positive?
            puts "講義室の利用に#{initial_conflict_count}件の競合が見つかりました．"
            puts '各競合について．優先する講義室利用情報を選択してください．'
        end

        loop do
            break if conflicts.empty?

            resolve_conflict(
                conflicts.first,
                conflict_index: resolved_conflict_count + 1,
                conflict_count: initial_conflict_count
            )
            resolved_conflict_count += 1

            lecture_room_management_informations = @lecture_room_management_information_repository.find_all
            conflicts = ConflictDetector.detect_conflicts(
                lecture_room_management_informations,
                managed_lecture_room_informations: managed_lecture_room_informations
            )
        end


        puts "#{initial_conflict_count}件の競合を解消しました．" if initial_conflict_count.positive?
    end

    def resolve_conflict(conflict, conflict_index: nil, conflict_count: nil)
        unless conflict.is_a?(Conflict)
            raise TypeError, "conflict must be a Conflict"
        end

        conflicting_informations = conflict.conflicting_informations
        information_groups = conflicting_informations.group_by(&:subject).values
        column_widths = column_widths_for(information_groups)
        print_conflict(conflict, conflict_index, conflict_count)
        options = information_groups.map { |informations| option_label_for(informations, column_widths) }
        selected_index = @interactive_menu.select_from_list(
            '候補一覧：優先する情報を1つ選択してください．',
            options,
            header: format_columns(['科目名・予約名', '担当者・予約者', '備考'], column_widths)
        )
        validate_selected_index(selected_index, information_groups.length)
        prioritized_informations = information_groups[selected_index]
        puts "科目名・予約名「#{prioritized_informations.first.subject}」が選択されました．"
        puts

        information_groups.each do |informations|
            next if informations == prioritized_informations

            remove_related_informations(informations.first)
        end
    end

    private

    def print_conflict(conflict, conflict_index, conflict_count)
        puts "--- 競合 #{conflict_index}/#{conflict_count} ---" if conflict_index && conflict_count
        puts "日時　： #{date_label_for(conflict.date)}　#{period_label_for(conflict.period)}"
        puts "講義室： #{conflict.room_name}"
        puts
    end

    def date_label_for(date)
        "#{date.year}年#{date.month}月#{date.day}日(#{WEEKDAY_LABELS[date.wday]})"
    end

    def period_label_for(periods)
        sorted_periods = periods.sort_by { |period| PeriodMaster::ORDER.fetch(period) }
        return period_text_for(sorted_periods.first) if sorted_periods.length == 1

        regular_periods = sorted_periods.reject { |period| period == :lunch }
        if regular_periods.length >= 2 && consecutive_regular_periods?(regular_periods)
            first_period = PeriodMaster::SYMBOL_TO_STRING.fetch(regular_periods.first)
            last_period = PeriodMaster::SYMBOL_TO_STRING.fetch(regular_periods.last)
            return "#{first_period}-#{last_period}限"
        end

        sorted_periods.map { |period| period_text_for(period) }.join('，')
    end

    def period_text_for(period)
        period_text = PeriodMaster::SYMBOL_TO_STRING.fetch(period)
        return period_text if period == :lunch

        "#{period_text}限"
    end

    def consecutive_regular_periods?(periods)
        period_numbers = periods.map { |period| PeriodMaster::SYMBOL_TO_STRING.fetch(period).to_i }
        period_numbers.each_cons(2).all? { |previous_period, current_period| current_period == previous_period + 1 }
    end

    def managed_lecture_room_informations
        @managed_lecture_room_information_repository.find_all
    end


    def remove_related_informations(information)
        @lecture_room_management_information_repository.find_all.each do |stored_information|
            next unless stored_information.date == information.date
            next unless stored_information.subject == information.subject

            @lecture_room_management_information_repository.remove(stored_information)
        end
    end

    def validate_selected_index(selected_index, option_count)
        return if selected_index.is_a?(Integer) && selected_index.between?(0, option_count - 1)

        raise RangeError, "selected index must be between 0 and #{option_count - 1}"
    end

    def column_widths_for(information_groups)
        rows = information_groups.map do |informations|
            representative = informations.first
            [representative.subject, representative.user, representative.comment]
        end
        columns = [['科目名・予約名', '担当者・予約者', '備考']] + rows

        (0...3).map do |index|
            columns.map { |row| display_width(row[index]) }.max
        end
    end

    def format_columns(values, column_widths)
        values.each_with_index.map do |value, index|
            value + (' ' * (column_widths[index] - display_width(value)))
        end.join('  ')
    end

    def display_width(value)
        value.each_char.sum { |character| character.ascii_only? ? 1 : 2 }
    end

    def option_label_for(informations, column_widths)
        representative = informations.first
        format_columns(
            [representative.subject, representative.user, representative.comment],
            column_widths
        )
    end
end
