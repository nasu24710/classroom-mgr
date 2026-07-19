require_relative '../test_helper'
require 'rbconfig'
require_relative '../../lib/excel_data_exporter'

class ExcelDataExporterTest < Minitest::Test
  def setup
    @exporter = ExcelDataExporter.new
    @file_name = 'excel_data_exporter_test'
    @output_file_path = File.join(ExcelDataExporter::OUTPUT_DIRECTORY, "#{@file_name}.xlsx")
  end

  def teardown
    File.delete(@output_file_path) if File.exist?(@output_file_path)
    File.delete("#{@output_file_path}.lock") if File.exist?("#{@output_file_path}.lock")
  end

  def test_new_returns_excel_data_exporter
    assert_instance_of ExcelDataExporter, ExcelDataExporter.new
  end

  def test_export_workbook
    workbook = RubyXL::Workbook.new

    @exporter.export(workbook, @file_name)

    assert File.exist?(@output_file_path)
  end

  def test_export_lock_prevents_another_process_from_acquiring_the_lock
    @exporter.send(:with_exclusive_lock, @output_file_path) do
      assert_equal 'blocked', lock_status_from_another_process
    end

    assert_equal 'locked', lock_status_from_another_process
  end

  def test_export_with_xlsx_extension_locks_the_actual_output_file
    workbook = RubyXL::Workbook.new
    file_name_with_extension = "#{@file_name}.xlsx"

    @exporter.stub(:with_exclusive_lock, ->(file_path, &block) do
      assert_equal @output_file_path, file_path
      block.call
    end) do
      @exporter.export(workbook, file_name_with_extension)
    end

    assert File.exist?(@output_file_path)
  end

  def test_export_validates_output_path_before_acquiring_lock
    workbook = RubyXL::Workbook.new
    lock_was_acquired = false

    @exporter.stub(:with_exclusive_lock, ->(_file_path) { lock_was_acquired = true }) do
      ApplicationPath.stub(:output_file_path, ->(*) { raise ApplicationPath::InvalidPathError }) do
        assert_raises(ApplicationPath::InvalidPathError) do
          @exporter.export(workbook, @file_name)
        end
      end
    end

    refute lock_was_acquired
  end

  def test_export_rejects_symbolic_link_lock_file
    workbook = RubyXL::Workbook.new
    lock_file_path = "#{@output_file_path}.lock"

    File.stub(:symlink?, ->(file_path) { file_path == lock_file_path }) do
      assert_raises(ApplicationPath::InvalidPathError) do
        @exporter.export(workbook, @file_name)
      end
    end
  end

  def test_export_converts_lock_file_link_follow_error_to_invalid_path_error
    workbook = RubyXL::Workbook.new

    File.stub(:open, ->(*) { raise Errno::ELOOP }) do
      assert_raises(ApplicationPath::InvalidPathError) do
        @exporter.export(workbook, @file_name)
      end
    end
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

  private

  def lock_status_from_another_process
    script = <<~RUBY
      File.open(ARGV[0], 'a+b') do |file|
        puts(file.flock(File::LOCK_EX | File::LOCK_NB) ? 'locked' : 'blocked')
      end
    RUBY

    IO.popen([RbConfig.ruby, '-e', script, "#{@output_file_path}.lock"], &:read).strip
  end
end
