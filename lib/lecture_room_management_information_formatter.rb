require "unicode/display_width"

class LectureRoomManagementInformationFormatter
  def self.to_formatted_string(lecture_room_management_informations)
    day_label_table = {
      mon: "月",
      tue: "火",
      wed: "水",
      thu: "木",
      fri: "金",
      sat: "土",
      sun: "日"
    }
    
    rows = [] # 各講義室管理情報の各要素の配列の配列
    column_widths = [] # 各講義室管理情報の各要素の列の最長文字数の配列
    formatted_string = "" # 講義室管理情報の各要素の列を揃えた文字列

    rows.append(["学期", "日付", "曜日", "時限", "講義室", "科目名・予約名", "担当者・予約者", "備考"])

    grouped_lecture_room_management_informations = {}

    lecture_room_management_informations.each do |info|
      sorted_periods = info.periods.sort_by { |period| PeriodMaster::ORDER[period] }
      
      # 以下の key に格納されている情報が同じ info をグループ化する
      key = [
        info.subject,
        info.date,
        sorted_periods
      ]

      if !grouped_lecture_room_management_informations.key?(key)
        grouped_lecture_room_management_informations[key] = {
          info: info,
          periods: sorted_periods,
          room_names: [],
          users: [],
          comments: []
        }
      end

      grouped_lecture_room_management_informations[key][:room_names].append(info.room_name)
      grouped_lecture_room_management_informations[key][:users].append(info.user)
      grouped_lecture_room_management_informations[key][:comments].append(info.comment)
    end

    grouped_lecture_room_management_informations.each_value do |grouped_info|
      info = grouped_info[:info]
      # 時限に関する処理
      sorted_periods = grouped_info[:periods]
      
      groups = []
      current_group = []

      sorted_periods.each do |period|
        if period == :lunch
          if current_group.any?
            groups.append(current_group)
            current_group = []
          end
          next
        end

        if current_group.empty?
          current_group.append(period)
          next
        end

        previous_period = current_group.last

        previous_number = PeriodMaster::SYMBOL_TO_STRING[previous_period].to_i
        current_number = PeriodMaster::SYMBOL_TO_STRING[period].to_i

        if current_number == previous_number + 1
          current_group.append(period)
        else
          groups.append(current_group)
          current_group = [period]
        end
      end

      if current_group.any?
        groups.append(current_group)
      end

      formatted_periods = groups.map do |group|
        if group.size == 1
          "#{PeriodMaster::SYMBOL_TO_STRING[group.first]}限"
        else
          first_period = PeriodMaster::SYMBOL_TO_STRING[group.first]
          last_period = PeriodMaster::SYMBOL_TO_STRING[group.last]
          "#{first_period}-#{last_period}限"
        end
      end.join('　')

      rows.append([
        info.term.to_s,
        info.date.strftime("%Y/%m/%d"),
        day_label_table[info.day_of_the_week],
        formatted_periods,
        grouped_info[:room_names].uniq.join('　'),
        info.subject.to_s,
        grouped_info[:users].uniq.reject(&:empty?).join('　'),
        grouped_info[:comments].uniq.reject(&:empty?).join('　')
      ])
    end

    # 講義室管理情報の各要素の列を揃える処理
    rows.each do |row|
      row.each_with_index do |value, index|
        width = Unicode::DisplayWidth.of(value)
        column_widths[index] = [column_widths[index].to_i, width].max
      end
    end

    rows.each do |row|
      formatted_row = row.each_with_index.map do |value, index|
        display_width = Unicode::DisplayWidth.of(value)
        padding_width = column_widths[index] - display_width + 2
        value + (" " * padding_width)
      end.join

      formatted_string += formatted_row.rstrip + "\n"
    end

    return formatted_string
  end
end
