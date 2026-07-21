require 'rubyXL'
require_relative 'period_master'
require_relative 'reservation_information'
require_relative 'excel_parse_error'

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

    # date (未入力 / yyyymmdd形式 / 存在しない日付)
    date = validate_date!(target_row, 'date', DATE)

    # event (未入力 / 65文字以上)
    event = validate_string!(target_row, 'event', 65, EVENT)

    # s_period，e_period (未入力 / 型 / 1-8)
    s_period = validate_integer!(target_row, 's_period', 1..8, S_PERIOD)
    e_period = validate_integer!(target_row, 'e_period', 1..8, E_PERIOD)

    # s_period が e_period より大きい (逆転チェック)
    if s_period > e_period
      row_info = target_row[S_PERIOD]&.row
      raise ExcelParseError.new(
        "'s_period' (#{s_period}) cannot be greater than 'e_period' (#{e_period}).",
        sheet: @worksheet.sheet_name, row: row_info, col: S_PERIOD
      )
    end
    period_symbols = generate_period_symbols(s_period, e_period)

    # user (未入力 / 65文字以上)
    user = validate_string!(target_row, 'user', 65, USER)

    # room (未入力 / 65文字以上)
    rooms_str = validate_string!(target_row, 'room', 65, ROOM)
    rooms = parse_room_name(rooms_str)


    return ReservationInformation.new(
      date,
      event,
      period_symbols,
      user,
      rooms
    )
  end

  ###########################################
  # バリデーションメソッド群
  ###########################################

  def validate_date!(target_row, field_name, col_index)
    cell = target_row[col_index]
    row_info = cell&.row

    if cell.nil? || cell.value.nil? || cell.value.to_s.strip.empty?
      raise ExcelParseError.new(
        "'#{field_name}' must not be empty.",
        sheet: @worksheet.sheet_name, row: row_info, col: col_index
      )
    end

    # Excel上で数値として入っている場合もあるため to_s する
    val = cell.value.to_s.strip

    unless val.match?(/\A\d{8}\z/)
      raise ExcelParseError.new(
        "'#{field_name}' must be in yyyymmdd format (e.g., 20260403).",
        sheet: @worksheet.sheet_name, row: row_info, col: col_index
      )
    end

    begin
      parsed_date = Date.strptime(val, "%Y%m%d")
    rescue Date::Error, ArgumentError
      raise ExcelParseError.new(
        "'#{field_name}' contains an invalid date (#{val}).",
        sheet: @worksheet.sheet_name, row: row_info, col: col_index
      )
    end

    parsed_date
  end
  private :validate_date!

  def validate_string!(target_row, field_name, max_length, col_index)
    cell = target_row[col_index]
    row_info = cell&.row

    if cell.nil? || cell.value.nil? || cell.value.to_s.strip.empty?
      raise ExcelParseError.new(
        "'#{field_name}' must not be empty.",
        sheet: @worksheet.sheet_name, row: row_info, col: col_index
      )
    end
    
    val = cell.value.to_s.strip
    if val.length >= max_length
      raise ExcelParseError.new(
        "'#{field_name}' must be less than #{max_length} characters. (Current: #{val.length})",
        sheet: @worksheet.sheet_name, row: row_info, col: col_index
      )
    end
    val
  end
  private :validate_string!

  def validate_integer!(target_row, field_name, valid_range, col_index)
    cell = target_row[col_index]
    row_info = cell&.row

    if cell.nil? || cell.value.nil? || cell.value.to_s.strip.empty?
      raise ExcelParseError.new(
        "'#{field_name}' must not be empty.",
        sheet: @worksheet.sheet_name, row: row_info, col: col_index
      )
    end

    val = cell.value
    
    # 型チェック (純粋な数値、かつ小数が含まれていないか)
    is_valid_type = false
    if val.is_a?(Integer)
      is_valid_type = true
    elsif val.is_a?(Float) && (val % 1).zero?
      is_valid_type = true
    end

    unless is_valid_type
      raise ExcelParseError.new(
        "'#{field_name}' must be an integer.",
        sheet: @worksheet.sheet_name, row: row_info, col: col_index
      )
    end

    int_val = val.to_i
    unless valid_range.include?(int_val)
      raise ExcelParseError.new(
        "'#{field_name}' must be between #{valid_range.min} and #{valid_range.max}. (Current: #{int_val})",
        sheet: @worksheet.sheet_name, row: row_info, col: col_index
      )
    end

    int_val
  end
  private :validate_integer!

  ############################################

  def generate_period_symbols(start_period, end_period)
    unless start_period.is_a?(Integer)
      raise TypeError, 'start_period must be a Integer.'
    end
    unless end_period.is_a?(Integer)
      raise TypeError, 'end_period must be a Integer.'
    end

    ordered_periods = PeriodMaster::SEQUENCE

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
