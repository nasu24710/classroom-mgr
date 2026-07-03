require_relative 'test_helper'
require_relative '../lib/excel_data_exporter'

class ExcelDataExporterTest < Minitest::Test
  def setup
    @exporter = ExcelDataExporter.new
    @file_name = 'excel_data_exporter_test'
    @output_file_path = File.join(ExcelDataExporter::OUTPUT_DIRECTORY, "#{@file_name}.xlsx")
  end

  def teardown
    File.delete(@output_file_path) if File.exist?(@output_file_path)
  end

  def test_new_returns_excel_data_exporter
    assert_instance_of ExcelDataExporter, ExcelDataExporter.new
  end

  def test_export_workbook
    workbook = RubyXL::Workbook.new

    @exporter.export(workbook, @file_name)

    assert File.exist?(@output_file_path)
  end

  def test_invalid_workbook
    assert_raises(TypeError) do
      @exporter.export('not a workbook', @file_name)
    end
  end

  def test_invalid_file_name
    assert_raises(TypeError) do
      @exporter.export(RubyXL::Workbook.new, 123)
    end
  end
end
