require 'fileutils'
require 'rubyXL'

class ExcelDataExporter
  OUTPUT_DIRECTORY = File.expand_path('../output', __dir__)

  def initialize
  end

  def export(workbook, file_name)
    unless workbook.is_a?(RubyXL::Workbook)
      raise TypeError, 'workbook must be a RubyXL::Workbook.'
    end

    unless file_name.is_a?(String)
      raise TypeError, 'file_name must be a String.'
    end

    FileUtils.mkdir_p(OUTPUT_DIRECTORY)

    workbook.write(File.join(OUTPUT_DIRECTORY, "#{file_name}.xlsx"))
  end
end
