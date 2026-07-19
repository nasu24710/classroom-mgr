require_relative '../test_helper'
require 'fileutils'
require 'tmpdir'
require_relative '../../lib/excel_data_loader'

class ApplicationPathTest < Minitest::Test
  def test_output_file_path_preserves_permission_errors_from_directory_resolution
    Dir.mktmpdir do |root_directory|
      FileUtils.mkdir(File.join(root_directory, 'output'))

      [Errno::EACCES, Errno::EPERM].each do |error_class|
        File.stub(:realpath, ->(_path) { raise error_class }) do
          assert_raises(error_class) do
            ApplicationPath.output_file_path('result', root_directory: root_directory)
          end
        end
      end
    end
  end

  def test_output_file_path_converts_path_resolution_error_to_invalid_path_error
    Dir.mktmpdir do |root_directory|
      FileUtils.mkdir(File.join(root_directory, 'output'))

      File.stub(:realpath, ->(_path) { raise Errno::ELOOP }) do
        assert_raises(ApplicationPath::InvalidPathError) do
          ApplicationPath.output_file_path('result', root_directory: root_directory)
        end
      end
    end
  end

  def test_output_file_path_preserves_read_only_file_system_error
    Dir.mktmpdir do |root_directory|
      FileUtils.stub(:mkdir_p, ->(_path) { raise Errno::EROFS }) do
        assert_raises(Errno::EROFS) do
          ApplicationPath.output_file_path(
            'result',
            root_directory: root_directory,
            create_directory: true
          )
        end
      end
    end
  end
end
