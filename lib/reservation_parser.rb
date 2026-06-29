require 'rubyXL'

class ReservationParser
  DATE = 0
  EVENT = 1
  S_PERIOD = 2
  E_PERIOD = 3
  USER = 4
  ROOM = 5

  def initialize(worksheet)
    unless worksheet.is_a?(RubyXL::Worksheet)
      raise TypeError, 'Worksheet must be a RubyXL::Worksheet.'
    end

    @worksheet = worksheet
  end

  def parse_reservation_worksheet
    reservation_informations = []

    row = 1
    loop do
      target_row = @worksheet[row]
      
      if target_row.nil?
        break
      end
      
      reservation_information = parse_entry(target_row)
      
      if reservation_information != nil
        reservation_informations.append(reservation_information)
      end
      
      row += 1
    end

    return reservation_informations
  end

  def parse_entry(target_row)
    unless target_row.is_a?(RubyXL::Row)
      raise TypeError, 'target_row must be a Ruby::Row.'
    end

    date = Date.strptime(target_row[DATE].value.to_s, "%Y%m%d")
    event = target_row[EVENT].value.to_s
    s_period = target_row[S_PERIOD].value.to_i
    e_period = target_row[E_PERIOD].value.to_i
    period_symbols = generate_period_symbols(s_period, e_period)
    user = target_row[USER].value.to_s
    rooms = parse_room_name(target_row[ROOM].value.to_s)

    return ReservationInformation.new(
      date,
      event,
      period_symbols,
      user,
      rooms
    )
  end

  def generate_period_symbols(start_period, end_period)
    unless start_period.is_a?(Integer)
      raise TypeError, 'start_period must be a Integer.'
    end
    unless end_period.is_a?(Integer)
      raise TypeError, 'end_period must be a Integer.'
    end

    ordered_periods = PeriodMaster::PERIOD_SYMBOLS

    start_index = ordered_periods.index("p#{start_period}".to_sym)
    end_index   = ordered_periods.index("p#{end_period}".to_sym)

    return ordered_periods[start_index..end_index]
  end

  def parse_room_name(room_name)
    unless room_name.is_a?(String)
      raise TypeError, 'room_name must be a String.'
    end

    return room_name.split('，')
  end
end # class ReservationParser
