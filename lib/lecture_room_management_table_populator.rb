#require 'lecture_room_management_table_building_result'
require_relative 'lecture_room_management_excel_formatter'

class LectureRoomManagementTablePopulator
  def initialize(lecture_room_management_table_building_result)
    unless lecture_room_management_table_building_result.is_a?(LectureRoomManagementTableBuildingResult)
      raise TypeError, "lecture_room_management_table_building_result must be a LectureRoomManagementTableBuildingResult"
    end 

    @lecture_room_management_table_building_result = lecture_room_management_table_building_result
  end

  def populate_entries(lecture_room_management_informations)
    unless lecture_room_management_informations.is_a?(Array)
      raise TypeError, "lecture_room_management_informations must be an Array"
    end 

    lecture_room_management_informations.each do |lecture_room_management_information|
      populate_entry(lecture_room_management_information)
    end

    return @lecture_room_management_table_building_result.workbook
  end

  def populate_entry(lecture_room_management_information)
    unless lecture_room_management_information.is_a?(LectureRoomManagementInformation)
      raise TypeError, "lecture_room_management_information must be a LectureRoomManagementInformation"
    end 

    date = lecture_room_management_information.date
    room_name = lecture_room_management_information.room_name
    periods = lecture_room_management_information.periods
    
    excel_formatter = LectureRoomManagementExcelFormatter.new
    excel_formatter_format = excel_formatter.format(lecture_room_management_information)

    worksheet, row_index =
      @lecture_room_management_table_building_result.row_map[[date,room_name]] ||
      @lecture_room_management_table_building_result.row_map[[date,room_name.unicode_normalize(:nfkc)]]

    periods.each do |period|
      column_index = @lecture_room_management_table_building_result.column_map[period]

      cell = worksheet.add_cell(row_index,column_index,"#{excel_formatter_format}")
      cell.change_font_size(8)
      cell.change_text_wrap(true)
      cell.change_border(:top,'thin')
      cell.change_border(:bottom,'thin')
      cell.change_border(:left,'thin')
      cell.change_border(:right,'thin')
      cell.change_horizontal_alignment('center')
      cell.change_vertical_alignment('center')
    end
  end
end
