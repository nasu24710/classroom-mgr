require 'date'
require 'rubyXL'
require_relative 'academic_calendar_comment_parser'
require_relative 'academic_year_converter'
require_relative 'academic_calendar_information'
require_relative 'day_attribute'

class AcademicCalendarParser
  def initialize(worksheet, stylesheet)
    unless worksheet.is_a?(RubyXL::Worksheet)
      raise TypeError, 'Worksheet must be a RubyXL::Worksheet.'
    end

    unless stylesheet.is_a?(RubyXL::Stylesheet)
      raise TypeError, 'Stylesheet must be a RubyXL::Stylesheet.'
    end

    @worksheet = worksheet
    @stylesheet = stylesheet
  end

  def parse_academic_calendar_worksheet
    title = get_data_title(1, 1)
    academic_year = parse_title(title)

    if academic_year.nil?
      return []
    end

    academic_calendar_comment_parser = AcademicCalendarCommentParser.new(@worksheet)

    comments = academic_calendar_comment_parser.parse_academic_calendar_comments(academic_year)

    term_periods = parse_term_periods(academic_year)

    cell_color_definitions = fetch_cell_color_definitions

    academic_calendar_informations = []

    [4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3].each do |month|
      calendar_year = AcademicYearConverter.academic_year_and_month_to_calendar_year(academic_year, month)

      start_row, start_column = month_grid_position(month)

      month_informations = parse_month_grid(calendar_year, month, start_row, start_column, term_periods, comments, cell_color_definitions)

      academic_calendar_informations.concat(month_informations)
    end
    return academic_calendar_informations
  end

  def month_grid_position(month)
    unless month.is_a?(Integer)
      raise TypeError, 'month must be an Integer.'
    end

    month_offset = (month - 4) % 12 # 4月=0, 5月=1, ..., 3月=11
    block_index = month_offset % 6
    start_row = 6 + block_index * 6 # 7行目が4月の開始行
    start_column = month_offset < 6 ? 3 : 14 # D列=3, O列=14
    [start_row, start_column]
  end
  private :month_grid_position

  def get_data_title(target_row, target_column)
    unless target_row.is_a?(Integer)
      raise TypeError, 'target_row must be an Integer.'
    end

    unless target_column.is_a?(Integer)
      raise TypeError, 'target_column must be an Integer.'
    end

    title_cell = @worksheet[target_row][target_column]
    title = title_cell.value.to_s.strip

    return title
  end

  def parse_title(title)
    unless title.is_a?(String)
      raise TypeError, 'title must be a String.'
    end

    year_match = title.match(/([0-9０-９]{4})/)

    return nil if year_match.nil?

    normalized_year = year_match[1].tr('０-９', '0-9').to_i

    return normalized_year
  end

  def parse_month_grid(calendar_year, month, start_row, start_column, term_periods, comments, cell_color_definitions)
      unless calendar_year.is_a?(Integer)
        raise TypeError, 'calendar_year must be an Integer.'
      end

      unless month.is_a?(Integer)
        raise TypeError, 'month must be an Integer.'
      end

      unless start_row.is_a?(Integer)
        raise TypeError, 'start_row must be an Integer.'
      end

      unless start_column.is_a?(Integer)
        raise TypeError, 'start_column must be an Integer.'
      end

      unless term_periods.is_a?(Hash)
        raise TypeError, 'term_periods must be a Hash.'
      end

      unless comments.is_a?(Hash)
        raise TypeError, 'comments must be a Hash.'
      end

      unless cell_color_definitions.is_a?(Hash)
        raise TypeError, 'cell_color_definitions must be a Hash.'
      end

      month_informations = []

      (0...6).each do |row_offset|
        target_row = start_row + row_offset

        week_informations = parse_week_grid(calendar_year, month, target_row, start_column, term_periods, comments, cell_color_definitions)

        month_informations.concat(week_informations)
      end

      return month_informations
  end

  def parse_week_grid(calendar_year, month, start_row, start_column, term_periods, comments, cell_color_definitions)
    unless calendar_year.is_a?(Integer)
      raise TypeError, 'calendar_year must be an Integer.'
    end

    unless month.is_a?(Integer)
      raise TypeError, 'month must be an Integer.'
    end

    unless start_row.is_a?(Integer)
      raise TypeError, 'start_row must be an Integer.'
    end

    unless start_column.is_a?(Integer)
      raise TypeError, 'start_column must be an Integer.'
    end

    unless term_periods.is_a?(Hash)
      raise TypeError, 'term_periods must be a Hash.'
    end

    unless comments.is_a?(Hash)
      raise TypeError, 'comments must be a Hash.'
    end

    unless cell_color_definitions.is_a?(Hash)
      raise TypeError, 'cell_color_definitions must be a Hash.'
    end

    week_informations = []

    days_of_the_week = [:sun, :mon, :tue, :wed, :thu, :fri, :sat]

    days_of_the_week.each_with_index do |day_of_the_week, col_offset|
      target_column = start_column + col_offset

      day_information = parse_day_cell(day_of_the_week, calendar_year, month, start_row, target_column, term_periods, comments, cell_color_definitions)

      week_informations << day_information unless day_information.nil?
    end

    return week_informations
  end

  def parse_day_cell(day_of_the_week, calendar_year, month, target_row, target_column, term_periods, comments, cell_color_definitions)
    unless day_of_the_week.is_a?(Symbol)
      raise TypeError, 'day_of_the_week must be a Symbol.'
    end

    unless calendar_year.is_a?(Integer)
      raise TypeError, 'calendar_year must be an Integer.'
    end

    unless month.is_a?(Integer)
      raise TypeError, 'month must be an Integer.'
    end

    unless target_row.is_a?(Integer)
      raise TypeError, 'target_row must be an Integer.'
    end

    unless target_column.is_a?(Integer)
      raise TypeError, 'target_column must be an Integer.'
    end

    unless term_periods.is_a?(Hash)
      raise TypeError, 'term_periods must be a Hash.'
    end

    unless comments.is_a?(Hash)
      raise TypeError, 'comments must be a Hash.'
    end

    unless cell_color_definitions.is_a?(Hash)
      raise TypeError, 'cell_color_definitions must be a Hash.'
    end

    cell = @worksheet[target_row][target_column]
    day = cell&.value

    return nil if day.nil?

    background_color = fetch_background_color(cell)
    border_color = fetch_border_color(cell)

    date = Date.new(calendar_year, month, day)

    day_attribute = parse_day_attribute(background_color, border_color, date, comments, cell_color_definitions)

    term = term_periods.find { |_term, range| range.cover?(date) }&.first

    if term.nil?
      term = term_periods
        .select { |_term, range| range.first <= date }
        .max_by { |_term, range| range.first }
        &.first
    end

    AcademicCalendarInformation.new(
      date: date,
      day_of_the_week: day_of_the_week,
      term: term,
      day_attribute: day_attribute
    )
  end

  def parse_day_attribute(background_color, border_color, date, comments, cell_color_definitions)
    unless background_color.is_a?(Hash) || background_color.nil?
      raise TypeError, 'background_color must be a Hash or nil.'
    end

    unless border_color.is_a?(Hash) || border_color.nil?
      raise TypeError, 'border_color must be a Hash or nil.'
    end

    unless date.is_a?(Date)
      raise TypeError, 'date must be a Date.'
    end

    unless comments.is_a?(Hash)
      raise TypeError, 'comments must be a Hash.'
    end

    unless cell_color_definitions.is_a?(Hash)
      raise TypeError, 'cell_color_definitions must be a Hash.'
    end


    border_colors = border_color.nil? ? nil : [
      border_color[:left_color],
      border_color[:right_color],
      border_color[:top_color],
      border_color[:bottom_color]
    ]

    definition_border_colors = ->(key) {
      bc = cell_color_definitions[key][:border_color]
      return nil if bc.nil?
      [bc[:left_color], bc[:right_color], bc[:top_color], bc[:bottom_color]]
    }
    
    is_day_of_the_week_change_border = !border_colors.nil? && border_colors == definition_border_colors.call(:day_of_the_week_change)
    is_makeup_class_border = !border_colors.nil? && border_colors == definition_border_colors.call(:makeup_class)

    day_of_the_week_change = nil
    is_makeup_class = false
    is_exam_period = false
    is_public_holiday = false
    is_holiday = false
    comment_descriptions = nil

    is_holiday = background_color == cell_color_definitions[:holiday][:background_color]

    date_comments = comments[date]

    unless date_comments.nil?
      if is_day_of_the_week_change_border
        day_of_the_week_change = date_comments
          .map(&:day_of_the_week_changes)
          .compact
          .first
      end

      is_public_holiday = date_comments.any?(&:is_public_holiday)

      comment_descriptions = date_comments.map(&:description)
    end

    is_makeup_class = is_makeup_class_border

    is_exam_period = background_color == cell_color_definitions[:exam_period][:background_color]

    DayAttribute.new(
      day_of_the_week_changes: day_of_the_week_change,
      is_makeup_class: is_makeup_class,
      is_exam_period: is_exam_period,
      is_public_holiday: is_public_holiday,
      is_holiday: is_holiday,
      comments: comment_descriptions
    )
  end

  def parse_term_periods(academic_year)
    unless academic_year.is_a?(Integer)
      raise TypeError, 'academic_year must be an Integer.'
    end

    term_periods = {}

    term_start_row = 46 # 47行目に1学期の期間が記載
    term_column = 4 # E列目に各学期の期間が記載

    (1..4).each do |term|
      row = term_start_row + (term - 1) * 2 # 各学期の期間は2行おきに記載されている
      dates = parse_term_period(row, term_column, academic_year)
      term_periods[term] = (dates[0]..dates[1])
    end

    return term_periods
  end

  def parse_term_period(target_row, target_column, academic_year)
    unless target_row.is_a?(Integer)
      raise TypeError, 'target_row must be an Integer.'
    end

    unless target_column.is_a?(Integer)
      raise TypeError, 'target_column must be an Integer.'
    end

    unless academic_year.is_a?(Integer)
      raise TypeError, 'academic_year must be an Integer.'
    end

    cell = @worksheet[target_row][target_column]
    cell_text = cell.value.to_s.strip
    
    match = cell_text.match(/(\d+)月(\d+)日[〜～~](\d+)月(\d+)日/)
    return nil if match.nil?

    start_month = match[1].to_i
    start_day = match[2].to_i
    end_month = match[3].to_i
    end_day = match[4].to_i

    start_year = AcademicYearConverter.academic_year_and_month_to_calendar_year(academic_year, start_month)
    end_year = AcademicYearConverter.academic_year_and_month_to_calendar_year(academic_year, end_month)

    start_date = Date.new(start_year, start_month, start_day)
    end_date = Date.new(end_year, end_month, end_day)

    return [start_date, end_date]
  end

  def fetch_cell_color_definitions
    exam_period_cell = @worksheet[54][1] # B55 に試験期間
    holiday_cell = @worksheet[46][12] # L47 に休日
    day_of_the_week_change_cell = @worksheet[48][12] # L49 に曜日変更
    makeup_class_cell = @worksheet[50][12] # L51 に補講日

    {
      holiday: {
        background_color: fetch_background_color(holiday_cell),
        border_color: fetch_border_color(holiday_cell)
      },
      exam_period: {
        background_color: fetch_background_color(exam_period_cell),
        border_color: fetch_border_color(exam_period_cell)
      },
      day_of_the_week_change: {
        background_color: fetch_background_color(day_of_the_week_change_cell),
        border_color: fetch_border_color(day_of_the_week_change_cell)
      },
      makeup_class: {
        background_color: fetch_background_color(makeup_class_cell),
        border_color: fetch_border_color(makeup_class_cell)
      }
    }
  end

  def fetch_background_color(cell)
    return nil if cell&.style_index.nil?

    xf = @stylesheet.cell_xfs[cell.style_index]
    return nil if xf.nil?

    fill = @stylesheet.fills[xf.fill_id]
    return nil if fill.nil?

    fg = fill.pattern_fill&.fg_color

    {
      fg_rgb: fg&.rgb,
      fg_theme: fg&.theme,
      fill_id: xf.fill_id,
      pattern: fill.pattern_fill&.pattern_type
    }
  end
  private :fetch_background_color

  def fetch_border_color(cell)
    return nil if cell&.style_index.nil?

    xf = @stylesheet.cell_xfs[cell.style_index]
    return nil if xf.nil?

    border = @stylesheet.borders[xf.border_id]
    return nil if border.nil?

    {
      left_color: border.left&.color&.rgb,
      right_color: border.right&.color&.rgb,
      top_color: border.top&.color&.rgb,
      bottom_color: border.bottom&.color&.rgb
    }
  end
  private :fetch_border_color
  
end
