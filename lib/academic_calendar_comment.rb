class AcademicCalendarComment < Data.define(:dates, :description, :day_of_the_week_changes, :is_public_holiday)
  def initialize(dates:, description:, day_of_the_week_changes:, is_public_holiday:)
    unless dates.is_a?(Array) && dates.all? { |date| date.is_a?(Date) }
      raise TypeError, 'dates must be an Array of Date objects.'
    end

    unless description.is_a?(String)
      raise TypeError, 'description must be a String.'
    end

    unless day_of_the_week_changes.is_a?(Symbol) || day_of_the_week_changes.nil?
      raise TypeError, 'day_of_the_week_changes must be a Symbol or nil.'
    end

    unless [true, false].include?(is_public_holiday)
      raise TypeError, 'is_public_holiday must be a Boolean.'
    end

    super(dates: dates.dup, description: description, day_of_the_week_changes: day_of_the_week_changes, is_public_holiday: is_public_holiday)
  end
end
