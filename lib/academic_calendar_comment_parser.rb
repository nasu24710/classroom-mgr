require 'rubyXL'
require_relative 'academic_calendar_comment_date_parser'
require_relative 'academic_calendar_comment'

class AcademicCalendarCommentParser
  DAY_OF_THE_WEEK_SYMBOLS = {
    '日' => :sun, '月' => :mon, '火' => :tue, '水' => :wed,
    '木' => :thu, '金' => :fri, '土' => :sat
  }.freeze
  HOLIDAY_KEYWORDS = [
    '昭和の日', '憲法記念日', 'みどりの日', 'こどもの日', '海の日',
    '山の日', '敬老の日', '秋分の日', 'スポーツの日', '文化の日',
    '勤労感謝の日', '元日', '成人の日', '建国記念の日', '天皇誕生日',
    '春分の日', '振替休日', '国民の休日'
  ].freeze
  
  def initialize(worksheet)
    unless worksheet.is_a?(RubyXL::Worksheet)
      raise TypeError, 'Worksheet must be a RubyXL::Worksheet.'
    end

    @worksheet = worksheet
  end

  def parse_academic_calendar_comments(academic_year)
    unless academic_year.is_a?(Integer)
      raise TypeError, 'academic_year must be an Integer.'
    end

    comments = {}

    [4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3].each do |month|
      start_row, start_column = comment_grid_position(month)

      month_comments = parse_academic_calendar_month_comments(academic_year, month, start_row, start_column)

      month_comments.each do |date, comment_array|
        comments[date] ||= []
        comments[date].concat(comment_array)
      end
    end

    return comments
  end

  def comment_grid_position(month)
    unless month.is_a?(Integer)
      raise TypeError, 'month must be an Integer.'
    end

    month_offset = (month - 4) % 12 # 4月=0, 5月=1, ..., 3月=11
    block_index = month_offset % 6 
    start_row = 6 + block_index * 6 # 7行目が4月の開始行
    start_column = month_offset < 6 ? 10 : 21 # K列=10, V列=21
    [start_row, start_column]
  end
  private :comment_grid_position

  def parse_academic_calendar_month_comments(academic_year, month, start_row, start_column)
    unless academic_year.is_a?(Integer)
      raise TypeError, 'academic_year must be an Integer.'
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

    comments = {}

    (0...6).each do |row_offset|
      target_row = start_row + row_offset

      comment = parse_academic_calendar_comment(academic_year, month, target_row, start_column)

      next if comment.nil?

      comment.each do |date, comment_array|
        comments[date] ||= []
        comments[date].concat(comment_array)
      end
    end
    
    return comments
  end

  def parse_academic_calendar_comment(academic_year, month, start_row, start_column)
    unless academic_year.is_a?(Integer)
      raise TypeError, 'academic_year must be an Integer.'
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

    comment = {}

    comment_cell = @worksheet[start_row][start_column]
    comment_text = comment_cell.value.to_s.strip

    if comment_text.empty?
      return nil
    end

    dates = AcademicCalendarCommentDateParser.parse(comment_text, academic_year, month)

    description_cell = @worksheet[start_row][start_column + 1]
    description_text = description_cell.value.to_s.strip

    if description_text.empty?
      return nil
    end

    day_of_the_week_change, is_holiday, is_university_festival = classify_type(description_text)
    description_text = description_text.gsub(/([月火水木金土日])曜日の授業(?:\([^)]*\))?(?:を行う)?/, '\1曜日授業')

    dates.each do |date|
      description_for_comment = is_university_festival ? '大学祭' : description_text

      academic_calendar_comment = AcademicCalendarComment.new(
        dates: [date],
        description: description_for_comment,
        day_of_the_week_changes: day_of_the_week_change,
        is_public_holiday: is_holiday
      )

      comment[date] ||= []
      comment[date] << academic_calendar_comment
    end
    
    if is_university_festival
      festival_comments = parse_university_festival_comment(academic_year, month, description_text)

      festival_comments.each do |festival_date, closures|
        comment[festival_date] ||= []
        comment[festival_date].concat(closures)
      end
    end

    return comment
  end

  def classify_type(description)
    unless description.is_a?(String)
      raise TypeError, 'description must be a String.'
    end

    day_of_the_week_change = nil

    DAY_OF_THE_WEEK_SYMBOLS.each do |day_name, symbol|
      if description.include?("#{day_name}曜日の授業")
        day_of_the_week_change = symbol
        break
      end
    end

    is_holiday = HOLIDAY_KEYWORDS.any? { |holiday| description.include?(holiday) }
    is_university_festival = description.include?("大学祭")

    [day_of_the_week_change, is_holiday, is_university_festival]
  end

  def parse_university_festival_comment(academic_year, month, description)
    unless academic_year.is_a?(Integer)
      raise TypeError, 'academic_year must be an Integer.'
    end

    unless month.is_a?(Integer)
      raise TypeError, 'month must be an Integer.'
    end

    unless description.is_a?(String)
      raise TypeError, 'description must be a String.'
    end

    comment = {}

    closure_match = description.match(/※\s*(.+?)\s*臨時休業/)

    return comment if closure_match.nil?

    closure_text = closure_match[1]
    closure_dates = AcademicCalendarCommentDateParser.parse(closure_text, academic_year, month)

    closure_dates.each do |date|
      comment[date] = [AcademicCalendarComment.new(
        dates: [date],
        description: '臨時休業',
        day_of_the_week_changes: nil,
        is_public_holiday: false
      )]
    end

    return comment
  end
end
