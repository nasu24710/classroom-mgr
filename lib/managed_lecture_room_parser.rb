require_relative 'managed_lecture_room_information'

class ManagedLectureRoomParser
  def initialize(worksheet)
    unless worksheet.is_a?(RubyXL::Worksheet)
      raise ArgumentError, '@worksheet must be RubyXL::Worksheet.'
    end
    @worksheet = worksheet
  end

  def parse_entry(target_row,target_column)
    unless target_row.is_a?(Integer)
      raise ArgumentError, 'row_number must be an Integer.'
    end
        
    unless target_column.is_a?(Integer)
      raise ArgumentError, 'row_number must be an Integer.'
    end

    row = @worksheet[target_row]
    cell = row&.[](target_column)

    lecture_room_name = cell&.value

    if lecture_room_name.nil?
      return nil
    end

    lecture_room_name = lecture_room_name.to_s.strip

    if lecture_room_name.empty?
      return nil
    end

    return ManagedLectureRoomInformation.new(lecture_room_name)
  end

  def parse_managed_lecture_room_worksheet
    managed_lecture_room_information_list = []
    target_column = 0

    @worksheet.each_with_index do |row,target_row|
      next if row.nil? || row.cells.all? { |cell| cell&.value.to_s.strip.empty? }

      information = parse_entry(target_row,target_column)

      unless information.nil?
        managed_lecture_room_information_list << information
      end
    end

    return managed_lecture_room_information_list
  end
end
