require 'rubyXL'

class TimetableParser
  CODE = 0
  SUBJECT = 1
  GRADE = 2
  TERM = 3
  WEEK = 4
  S_PERIOD = 5
  E_PERIOD = 6
  USER = 7
  ROOM = 8

  def initialize(worksheet)
    unless worksheet.is_a?(RubyXL::Worksheet)
      raise TypeError, 'worksheet must be a RubyXL::Worksheet.'
    end

    @worksheet = worksheet
  end

  def parse_timetable_worksheet
    timetable_informations = []

    row = 1
    loop do
      target_row = @worksheet[row]
      
      if target_row.nil?
        break
      end

      timetable_information = parse_entry(target_row)
      
      if timetable_information != nil
        timetable_informations.append(timetable_information)
      end

      row += 1
    end

    return timetable_informations
  end

  def parse_entry(target_row)
    day_table = {
      "Mon" => :mon,
      "Tue" => :tue,
      "Wed" => :wed,
      "Thu" => :thu,
      "Fri" => :fri
    }

day_of_week = day_table[target_row[WEEK].value.to_s]

    unless target_row.is_a?(RubyXL::Row)
      raise TypeError, 'target_row must be a RubyXL::Row.'
    end

    subject = target_row[SUBJECT].value.to_s
    term = target_row[TERM].value.to_i
    day_of_week = day_table[target_row[WEEK].value.to_s]
    s_period = target_row[S_PERIOD].value.to_i
    e_period = target_row[E_PERIOD].value.to_i
    period_symbols = generate_period_symbols(s_period, e_period)
    teacher = target_row[USER].value.to_s
    rooms = parse_room_name(target_row[ROOM].value.to_s)

    return TimetableInformation.new(
      subject,
      term,
      day_of_week,
      period_symbols,
      teacher,
      rooms
    )
  end

  def generate_period_symbols(start_period, end_period)
    unless start_period.is_a?(Integer)
      raise TypeError, 'start_period must be a Integer.'
    end
    unless end_period.is_a?(Integer)
      raise TypeError, 'end_period must be a Integer'
    end
    
    ordered_periods = PeriodMaster::PERIOD_SYMBOLS

    start_index = ordered_periods.index("p#{start_period}".to_sym)
    end_index   = ordered_periods.index("p#{end_period}".to_sym)

    sliced_periods = ordered_periods[start_index..end_index]
    
    return sliced_periods.reject { |period| period == :lunch}
  end

  def parse_room_name(room_name)
    unless room_name.is_a?(String)
      raise TypeError, 'room_name must be a String.'
    end
    
    return room_name.split(',')
  end
end
