require 'rubyXL'

class ExcelDataLoader
  def self.load_xlsx_file(directory_path)
    xlsx_files = Dir.glob(File.join(directory_path, '*.xlsx'))

    if xlsx_files.length != 1
      return nil
    end

    xlsx_file = xlsx_files[0]
    workbook = RubyXL::Parser.parse(xlsx_file)

    return workbook
  end
    
  def self.load_academic_calendar_xlsx_file(directory_name)
    unless directory_name.is_a?(String)
      raise TypeError, 'directory_name must be a String.'
    end

    load_xlsx_file("data/#{directory_name}/学年暦")
  end

  def self.load_timetable_xlsx_file(directory_name)
    unless directory_name.is_a?(String)
      raise TypeError, 'directory_name must be a String.'
    end

    load_xlsx_file("data/#{directory_name}/時間割")
  end

  def self.load_reservation_xlsx_file(directory_name)
    unless directory_name.is_a?(String)
      raise TypeError, 'directory_name must be a String.'
    end

    load_xlsx_file("data/#{directory_name}/予約")
  end

  def self.load_managed_lecture_room_xlsx_file
    load_xlsx_file("data/管理対象講義室")
  end
end # class ExcelDataLoader
