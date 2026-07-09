require 'rubyXL'
require 'rubyXL/convenience_methods'
require_relative 'lecture_room_management_table_building_result'

class LectureRoomManagementTableBuilder
  def build(academic_calendar_informations,managed_lecture_room_informations)
    workbook = RubyXL::Workbook.new
    # 各学期の日付を書きこむ行の初期位置を保存   
    term_monthday_row_indexs = [4,4,4,4]
    # 各学期の日付の曜日を書きこむ行の初期位置を保存   
    term_day_of_week_row_indexs = [5,5,5,5]
    # 各学期の講義室名を書きこむ行の初期位置を保存
    term_managed_lecture_room_information_row_indexs = [4,4,4,4]

    workbook.worksheets.clear

    row_map = {}
    column_map = define_column_map()

    academic_calendar_informations.each do |academic_calendar_information|
      term = academic_calendar_information.term
      worksheet_name = "#{term}学期"
      
      day_of_the_week = academic_calendar_information.day_of_the_week

      worksheet = workbook[worksheet_name]

      # 該当する学期のワークシートがない場合に生成する
      if worksheet.nil?
        worksheet = workbook.add_worksheet(worksheet_name)
        write_header(worksheet,academic_calendar_information.date.year,term)
        worksheet.merge_cells('B1:K1')
        worksheet.change_column_width(0, 14)
        worksheet.change_column_width(1, 10.5)
        worksheet.change_column_width(2, 11)
        worksheet.change_column_width(3, 11)
        worksheet.change_column_width(4, 11)
        worksheet.change_column_width(5, 11)
        worksheet.change_column_width(6, 11)
        worksheet.change_column_width(7, 11)
        worksheet.change_column_width(8, 11)
        worksheet.change_column_width(9, 11)
        worksheet.change_column_width(10, 11)
      
        if worksheet.sheet_views.nil?
          worksheet.sheet_views = RubyXL::WorksheetViews.new
        end 

        if worksheet.sheet_views.empty?
          worksheet.sheet_views << RubyXL::WorksheetView.new(workbook_view_id: 0) 
        end

        worksheet.sheet_views[0].pane =
          RubyXL::Pane.new(
            y_split: 4,
            top_left_cell: 'A5',
            active_pane: 'bottomLeft',
            state: 'frozen'
          )
      end

      # 日付データをセルに登録し、体裁を整える。
      month_day_row = term_monthday_row_indexs[term-1] 
      month_day_string = format_date(academic_calendar_information.date)
      month_day_cell = worksheet.add_cell(month_day_row,0,"#{month_day_string}")
      month_day_cell.change_font_size(12)
      change_alignment(month_day_cell)  
      term_monthday_row_indexs[term-1] = term_monthday_row_indexs[term-1] + managed_lecture_room_informations.length + 1
      month_day_row = month_day_row + 2

      # 授業曜日の変更をセルに登録する。
      if academic_calendar_information.day_attribute.day_of_the_week_changes == :mon
        day_of_the_week_changes_cell = worksheet.add_cell(month_day_row,0,"月曜日の授業")
      elsif academic_calendar_information.day_attribute.day_of_the_week_changes == :tue
        day_of_the_week_changes_cell = worksheet.add_cell(month_day_row,0,"火曜日の授業")
      elsif academic_calendar_information.day_attribute.day_of_the_week_changes == :wed
        day_of_the_week_changes_cell = worksheet.add_cell(month_day_row,0,"水曜日の授業")
      elsif academic_calendar_information.day_attribute.day_of_the_week_changes == :thu
        day_of_the_week_changes_cell = worksheet.add_cell(month_day_row,0,"木曜日の授業")
      elsif academic_calendar_information.day_attribute.day_of_the_week_changes == :fri
        day_of_the_week_changes_cell = worksheet.add_cell(month_day_row,0,"金曜日の授業")
      end

      if day_of_the_week_changes_cell
        day_of_the_week_changes_cell.change_font_color("00B050") 
        change_alignment(day_of_the_week_changes_cell)      
        day_of_the_week_changes_cell.change_font_size(12)
        month_day_row = month_day_row + 1
      end

      # 補講日をセルに登録する。
      if academic_calendar_information.day_attribute.is_makeup_class == true
        makeup_class_cell = worksheet.add_cell(month_day_row,0,"補講日")
        month_day_row = month_day_row + 1
        makeup_class_cell.change_font_size(12)
        makeup_class_cell.change_font_color("00B050") 
        change_alignment(makeup_class_cell) 
      end

      # 試験期間をセルに登録する。
      if academic_calendar_information.day_attribute.is_exam_period == true
        exam_period_cell = worksheet.add_cell(month_day_row,0,"試験期間")
        month_day_row = month_day_row + 1
        exam_period_cell.change_font_size(12)
        exam_period_cell.change_font_color("FF0000") 
        change_alignment(exam_period_cell) 
      end

      # 休業日をセルに登録する。
      if academic_calendar_information.day_attribute.is_public_holiday == true
        public_holiday_cell = worksheet.add_cell(month_day_row,0,"休業日")
        month_day_row = month_day_row + 1
        public_holiday_cell.change_font_size(12)
        public_holiday_cell.change_font_color("00B050") 
        change_alignment(public_holiday_cell) 
      end

      # コメント（備考）の数だけセルに登録していく。
      unless academic_calendar_information.day_attribute.comments.nil?
        academic_calendar_information.day_attribute.comments.each.with_index do |comment,index|
          comment_cell = worksheet.add_cell(month_day_row+index, 0, "#{comment}")
          comment_cell.change_text_wrap(true)
          if academic_calendar_information.day_attribute.is_holiday == true && index == 0 
            comment_cell.change_font_color("FF0000") 
          else
            comment_cell.change_font_color("00B050")
          end

          comment_cell.change_font_size(12)
          change_alignment(comment_cell)
        end
      end

      # 日付に対応する曜日をセルに登録する。
      day_of_the_week_row = term_day_of_week_row_indexs[term-1]
      managed_lecture_room_row = term_managed_lecture_room_information_row_indexs[term-1]
      if day_of_the_week == :mon
        day_of_the_week_cell = worksheet.add_cell(day_of_the_week_row,0,"月曜日")      
        change_alignment(day_of_the_week_cell)        
        row_height = 30
      elsif day_of_the_week == :tue
        day_of_the_week_cell = worksheet.add_cell(day_of_the_week_row,0,"火曜日")      
        change_alignment(day_of_the_week_cell)        
        row_height = 30  
      elsif day_of_the_week == :wed
        day_of_the_week_cell = worksheet.add_cell(day_of_the_week_row,0,"水曜日")      
        change_alignment(day_of_the_week_cell) 
        row_height = 30         
      elsif day_of_the_week == :thu
        day_of_the_week_cell = worksheet.add_cell(day_of_the_week_row,0,"木曜日")      
        change_alignment(day_of_the_week_cell)    
        row_height = 30  
      elsif day_of_the_week == :fri
        day_of_the_week_cell = worksheet.add_cell(day_of_the_week_row,0,"金曜日")      
        change_alignment(day_of_the_week_cell)           
        row_height = 30
      elsif day_of_the_week == :sat
        day_of_the_week_cell = worksheet.add_cell(day_of_the_week_row,0,"土曜日")      
        change_alignment(day_of_the_week_cell)             
        day_of_the_week_cell.change_font_color("0000FF")       
        row_height = 18.8
      else
        day_of_the_week_cell = worksheet.add_cell(day_of_the_week_row,0,"日曜日")      
        change_alignment(day_of_the_week_cell)     
        day_of_the_week_cell.change_font_color("FF0000") 
        row_height = 18.8
      end
    
      day_of_the_week_cell.change_font_size(12)

      # 各日付の管理対象講義室をセルに登録する。
      managed_lecture_room_informations.each do |managed_lecture_room_information|
        managed_lecture_room_cell = worksheet.add_cell(managed_lecture_room_row,1,"#{managed_lecture_room_information.room_name}")
        row_map[[academic_calendar_information.date,managed_lecture_room_information.room_name]] = [worksheet,managed_lecture_room_row]
        row_map[[academic_calendar_information.date,managed_lecture_room_information.room_name.unicode_normalize(:nfkc)]] = [worksheet,managed_lecture_room_row]
        worksheet.change_row_height(managed_lecture_room_row, row_height)
        managed_lecture_room_cell.change_font_size(9)

        (1..10).each do |column_index|
          cell = worksheet[managed_lecture_room_row]&.[](column_index)

          if cell.nil?
            cell = worksheet.add_cell(managed_lecture_room_row, column_index, "")
          end

          apply_thin_border(cell)
          change_alignment(cell)
        end   

        managed_lecture_room_row = managed_lecture_room_row + 1
      end

      term_day_of_week_row_indexs[term-1] = term_day_of_week_row_indexs[term-1] + managed_lecture_room_informations.length + 1

      term_managed_lecture_room_information_row_indexs[term-1] = term_managed_lecture_room_information_row_indexs[term-1] + managed_lecture_room_informations.length + 1      
    end

    return LectureRoomManagementTableBuildingResult.new(workbook,row_map,column_map)
  end

  def define_column_map
    return {p1:2,p2:3,p3:4,p4:5,lunch:6,p5:7,p6:8,p7:9,p8:10}
  end

  def format_date(date)
    unless date.is_a?(Date)
      raise TypeError, "date must be a Date"
    end

    return "（　#{date.month}/#{date.day}　）"
  end

  def write_header(worksheet,academic_year,term)
    unless worksheet.is_a?(RubyXL::Worksheet)
      raise TypeError, "worksheet must be a RubyXL::Worksheet"
    end

    unless academic_year.is_a?(Integer)
      raise TypeError, "academic_year must be an Integer"
    end

    unless term.is_a?(Integer)
      raise TypeError, "term must be an Integer"
    end

    cell = worksheet.add_cell(0,1,"#{academic_year}年度情報工学コース/情報工学先進コース講義室等使用状況（#{term}学期）")
    change_alignment(cell)
    cell.change_font_size(14)

    cell = worksheet.add_cell(2,1,"時限")
    change_alignment(cell)  
    apply_thin_border(cell)
    cell = worksheet.add_cell(2,2,"1")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(2,3,"2")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(2,4,"3")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(2,5,"4")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(2,6,"昼休み")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(2,7,"5")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(2,8,"6")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(2,9,"7")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(2,10,"8")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(3,1,"時間")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(3,2,"8:40~9:30")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(3,3,"9:40~10:30")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(3,4,"10:45~11:35")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(3,5,"11:45~12:35")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(3,6,"12:35~13:25")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(3,7,"13:25~14:15")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(3,8,"14:25~15:15")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(3,9,"15:30~16:20")
    apply_thin_border(cell)
    change_alignment(cell)  
    cell = worksheet.add_cell(3,10,"16:30~17:20")
    apply_thin_border(cell)
    change_alignment(cell)  
    #if worksheet.merged_cells.nil?
    #  worksheet.merged_cells = RubyXL::MergedCells.new
    #end

    #worksheet.merged_cells.merge_cell << RubyXL::MergedCell.new(ref: 'B1:K1')
  end

  def apply_thin_border(cell)
    cell.change_border(:top,'thin')
    cell.change_border(:bottom,'thin')
    cell.change_border(:left,'thin')
    cell.change_border(:right,'thin')
  end

  def change_alignment(cell)
    cell.change_horizontal_alignment('center')
    cell.change_vertical_alignment('center')
  end  

  def write_managed_lecture_room_rows(worksheet,managed_lecture_room_informations,managed_lecture_room_row,row_height)
    managed_lecture_room_informations.each do |managed_lecture_room_information|
      managed_lecture_room_cell = worksheet.add_cell(managed_lecture_room_row,1,"#{managed_lecture_room_information.room_name}")
      worksheet.change_row_height(managed_lecture_room_row, row_height)

      (1..10).each do |column_index|
        cell = worksheet[managed_lecture_room_row]&.[](column_index)

        if cell.nil?
          cell = worksheet.add_cell(managed_lecture_room_row, column_index, "")
        end

        apply_thin_border(cell)
        change_alignment(cell)
      end   

      managed_lecture_room_row = managed_lecture_room_row + 1
    end
  end
end 
