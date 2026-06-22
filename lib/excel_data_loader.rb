require 'rubyXL'

class ExcelDataLoader
  def load_academic_calendar_xlsx_file(directory_name)
    unless directory_name.is_a?(String)
      raise ArgumentError, 'directory_name must be a String.'
    end

    directory_path = 'data/' + directory_name + '/学年暦'

    xlsx_files = Dir.glob(File.join(directory_path, '*.xlsx'))
    if xlsx_files.length != 1
      return nil
    end
    xlsx_file = xlsx_files[0]

    workbook = RubyXL::Parser.parse(xlsx_file)

    return workbook
  end

  def load_timetable_xlsx_file(directory_name)
    unless directory_name.is_a?(String)
      raise ArgumentError, 'directory_name must be a String.'
    end

    directory_path = 'data/' + directory_name + '/時間割'

    xlsx_files = Dir.glob(File.join(directory_path, '*.xlsx'))
    if xlsx_files.length != 1
      return nil
    end
    xlsx_file = xlsx_files[0]

    workbook = RubyXL::Parser.parse(xlsx_file)

    return workbook
  end

  def load_reservation_xlsx_file(directory_name)
    unless directory_name.is_a?(String)
      raise ArgumentError, 'directory_name must be a String.'
    end

    directory_path = 'data/' + directory_name + '/予約'

    xlsx_files = Dir.glob(File.join(directory_path, '*.xlsx'))
    if xlsx_files.length != 1
      return nil
    end
    xlsx_file = xlsx_files[0]

    workbook = RubyXL::Parser.parse(xlsx_file)

    return workbook
  end

  def load_managed_lecture_room_xlsx_file
    directory_path = 'data/管理対象講義室'

    xlsx_files = Dir.glob(File.join(directory_path, '*.xlsx'))
    if xlsx_files.length != 1
      return nil
    end
    xlsx_file = xlsx_files[0]

    workbook = RubyXL::Parser.parse(xlsx_file)

    return workbook
  end
end # class ExcelDataLoader
