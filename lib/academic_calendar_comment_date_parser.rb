require 'date'

class AcademicCalendarCommentDateParser
  def self.parse(date_string, academic_year, month)
    unless date_string.is_a?(String)
      raise TypeError, 'date_string must be a String.'
    end

    unless academic_year.is_a?(Integer)
      raise TypeError, 'academic_year must be an Integer.'
    end

    unless month.is_a?(Integer)
      raise TypeError, 'month must be an Integer.'
    end

    normalized = normalize(date_string)

    parsed_dates = parse_slash_separated_dates(normalized, academic_year) ||
      parse_cross_month_range(normalized, academic_year) ||
      parse_comma_separated_days(normalized, academic_year, month) ||
      parse_same_month_range(normalized, academic_year, month) ||
      parse_single_day(normalized, academic_year, month) ||
      []

    return parsed_dates
  end

  def self.normalize(date_string)
    text = date_string.dup
    text = text.gsub(/\([^)]*\)/, '')   # (予定)などの括弧書きを除去
    text = text.gsub(/[\r\n]+/, '')      # 改行を除去
    text = text.gsub(/[~～]/, '〜')      # 半角~と全角～を〜に正規化
    text.strip
  end
  private_class_method :normalize

  def self.calendar_year_for(academic_year, month)
    month >= 4 ? academic_year : academic_year + 1
  end
  private_class_method :calendar_year_for

  # 例: "10/30,11/2"（両方に月あり）, "10/30,2"（2番目は日のみ、月は前の要素から引き継ぐ）
  def self.parse_slash_separated_dates(text, academic_year)
    return nil unless text.match(%r{\d+/\d+})

    segments = text.split(/[,，、]/)

    last_month = nil

    dates = segments.map do |segment|
      match = segment.match(%r{(\d+)/(\d+)})

      if match
        current_month = match[1].to_i
        day = match[2].to_i
      else
        day_only_match = segment.match(/(\d+)/)
        next nil if day_only_match.nil? || last_month.nil?

        current_month = last_month
        day = day_only_match[1].to_i
      end

      last_month = current_month

      calendar_year = calendar_year_for(academic_year, current_month)
      Date.new(calendar_year, current_month, day)
    end

    dates.compact
  end
  private_class_method :parse_slash_separated_dates

  # 例: "10月30日〜11月2日", "25日〜1月4日"
  def self.parse_cross_month_range(text, academic_year)
    match = text.match(/(?:(\d+)月)?(\d+)日\s*〜\s*(\d+)月(\d+)日/)

    return nil if match.nil?

    start_month = match[1]
    start_day = match[2].to_i
    end_month = match[3].to_i
    end_day = match[4].to_i

    # start_monthが省略されている場合、end_monthの前月とみなす
    start_month = start_month ? start_month.to_i : (end_month - 1 == 0 ? 12 : end_month - 1)

    start_year = calendar_year_for(academic_year, start_month)
    end_year = calendar_year_for(academic_year, end_month)

    start_date = Date.new(start_year, start_month, start_day)
    end_date = Date.new(end_year, end_month, end_day)

    (start_date..end_date).to_a
  end
  private_class_method :parse_cross_month_range

  # 例: "16,17日", "16，17日"
  def self.parse_comma_separated_days(text, academic_year, month)
    return nil unless text.match(/\d+\s*[,，、]/)

    days = text.scan(/(\d+)\s*[,，、日]/).flatten.map(&:to_i).uniq

    return nil if days.empty?

    calendar_year = calendar_year_for(academic_year, month)
    days.map { |day| Date.new(calendar_year, month, day) }
  end
  private_class_method :parse_comma_separated_days

  # 例: "7〜9日"
  def self.parse_same_month_range(text, academic_year, month)
    match = text.match(/(\d+)\s*〜\s*(\d+)日/)

    return nil if match.nil?

    start_day = match[1].to_i
    end_day = match[2].to_i

    calendar_year = calendar_year_for(academic_year, month)

    (start_day..end_day).map { |day| Date.new(calendar_year, month, day) }
  end
  private_class_method :parse_same_month_range

  # 例: "2日", "注：7日"
  def self.parse_single_day(text, academic_year, month)
    match = text.match(/(\d+)日/)

    return nil if match.nil?

    day = match[1].to_i
    calendar_year = calendar_year_for(academic_year, month)

    [Date.new(calendar_year, month, day)]
  end
  private_class_method :parse_single_day
end
