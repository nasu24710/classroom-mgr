require 'fileutils'
require 'rubyXL'
require_relative 'excel_data_loader' # ApplicationPathクラスを利用するため

class ExcelDataExporter
  # ApplicationPathと同じ，アプリケーションルート直下のoutputを公開する。
  OUTPUT_DIRECTORY = ApplicationPath::OUTPUT_DIRECTORY

  def initialize
  end

  def export(workbook, file_name)
    unless workbook.is_a?(RubyXL::Workbook)
      raise TypeError, 'workbook must be a RubyXL::Workbook.'
    end

    unless file_name.is_a?(String)
      raise TypeError, 'file_name must be a String.'
    end

    # 出力先を検証してから，同じパスをロックと書き込みの両方に使用する。
    output_file_path = ApplicationPath.output_file_path(file_name, create_directory: true)

    with_exclusive_lock(output_file_path) do
      workbook.write(output_file_path)
    end
  end

  private

  def with_exclusive_lock(file_path)
    lock_file_path = "#{file_path}.lock"
    if File.symlink?(lock_file_path)
      raise ApplicationPath::InvalidPathError, 'lock file must not be a symbolic link.'
    end

    lock_open_flags = File::RDWR | File::CREAT
    lock_open_flags |= File::NOFOLLOW if File.const_defined?(:NOFOLLOW)

    File.open(lock_file_path, lock_open_flags, 0o600) do |lock_file|
      lock_file.flock(File::LOCK_EX)

      begin
        yield
      ensure
        lock_file.flock(File::LOCK_UN)
      end
    end
  rescue Errno::ELOOP
    raise ApplicationPath::InvalidPathError, 'lock file must not be a symbolic link.'
  end
end
