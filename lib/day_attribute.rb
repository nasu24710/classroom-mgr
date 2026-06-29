require 'date'

class DayAttribute < Data.define(:day_of_the_week_changes, :is_makeup_class, :is_exam_period, :is_public_holiday, :is_holiday, :comments)
    def initialize(day_of_the_week_changes:, is_makeup_class:, is_exam_period:, is_public_holiday:, is_holiday:, comments:)
        unless day_of_the_week_changes.is_a?(Symbol) || day_of_the_week_changes.nil?
            raise TypeError, "day_of_the_week_changes must be a Symbol or nil"
        end
        unless [true, false].include?(is_makeup_class)
            raise TypeError, "is_makeup_class must be a Boolean"
        end
        unless [true, false].include?(is_exam_period)
            raise TypeError, "is_exam_period must be a Boolean"
        end
        unless [true, false].include?(is_public_holiday)
            raise TypeError, "is_public_holiday must be a Boolean"
        end
        unless [true, false].include?(is_holiday)
            raise TypeError, "is_holiday must be a Boolean"
        end
        unless comments.is_a?(Array) && comments.all? { |c| c.is_a?(String) } || comments.nil?
            raise TypeError, "comments must be an Array of Strings or nil"
        end

        super(day_of_the_week_changes: day_of_the_week_changes, is_makeup_class: is_makeup_class, is_exam_period: is_exam_period, is_public_holiday: is_public_holiday, is_holiday: is_holiday, comments: comments&.dup)
    end
end
