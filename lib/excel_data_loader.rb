require 'rubyXL'
require 'zip'
require 'fileutils'
require 'pathname'

class ExcelDataLoader
  class InvalidExcelFileError < StandardError; end
  class MultipleExcelFilesError < StandardError; end

  def self.load_xlsx_file(directory_path)
    xlsx_files = Dir.glob(File.join(directory_path, '*.xlsx'))

    # ファイル未配置と複数配置を区別し，複数配置はデータ構成エラーとする。
    return nil if xlsx_files.empty?

    if xlsx_files.length > 1
      raise MultipleExcelFilesError, "#{directory_path} に複数のxlsxファイルが存在します。"
    end

    xlsx_file = xlsx_files[0]
    # Excelファイル自体が外部を指すシンボリックリンクでないことを確認する。
    xlsx_file = ApplicationPath.existing_child_path(directory_path, File.basename(xlsx_file))

    begin
      workbook = with_exclusive_lock(xlsx_file) do
        RubyXL::Parser.parse(xlsx_file)
      end
    rescue Zip::Error => e
      raise InvalidExcelFileError, "#{xlsx_file} は有効なxlsxファイルではありません: #{e.message}"
    end

    return workbook
  end

  def self.with_exclusive_lock(file_path)
    File.open("#{file_path}.lock", 'a+b') do |lock_file|
      lock_file.flock(File::LOCK_EX)

      begin
        yield
      ensure
        lock_file.flock(File::LOCK_UN)
      end
    end
  end
  private_class_method :with_exclusive_lock

  def self.load_academic_calendar_xlsx_file(directory_path)
    unless directory_path.is_a?(String)
      raise TypeError, 'directory_name must be a String.'
    end

    load_xlsx_file(ApplicationPath.existing_child_path(directory_path, '学年暦'))
  end

  def self.load_timetable_xlsx_file(directory_path)
    load_xlsx_file(ApplicationPath.existing_child_path(directory_path, '時間割'))
  end

  def self.load_reservation_xlsx_file(directory_path)
    load_xlsx_file(ApplicationPath.existing_child_path(directory_path, '予約'))
  end

  def self.load_managed_lecture_room_xlsx_file
    load_xlsx_file(File.join(ApplicationPath::DATA_DIRECTORY, '管理対象講義室'))
  end
end # class ExcelDataLoader

# read/writeで共通利用する，アプリケーションルート基準のパス生成・検証
class ApplicationPath
  class InvalidPathError < StandardError; end

  # 実行時のカレントディレクトリではなく，main.rbがある位置をルートとする。
  ROOT_DIRECTORY = File.expand_path('..', __dir__).freeze
  DATA_DIRECTORY = File.join(ROOT_DIRECTORY, 'data').freeze
  OUTPUT_DIRECTORY = File.join(ROOT_DIRECTORY, 'output').freeze

  class << self
    def read_directory(directory_name, root_directory: ROOT_DIRECTORY)
      raise TypeError, 'directory_name must be a String.' unless directory_name.is_a?(String)

      # Windows形式の区切りも同じ基準で正規化できるよう「/」へ統一する。
      normalized_name = directory_name.tr('\\', '/')

      # 絶対パスやドライブ指定は許可せず，相対パスだけをdata基準で解決
      if normalized_name.empty? || normalized_name.strip.empty? ||
         Pathname.new(normalized_name).absolute? || normalized_name.match?(/\A[A-Za-z]:/)
        raise InvalidPathError, 'read directory must be a direct child of data.'
      end

      data_directory = verified_base_directory(File.join(root_directory, 'data'), root_directory)
      candidate = File.expand_path(normalized_name, data_directory)
      # 「../data/2026」のような入力も，正規化後にdata直下なら許可
      # 正規化後と実体解決後の両方でdata直下にあることを確認
      ensure_direct_child!(candidate, data_directory)
      ensure_existing_path_is_inside!(candidate, data_directory)
      candidate
    end

    # 学年暦、時間割、予約の各Excelファイルのパスを取得
    def existing_child_path(parent_directory, child_name)
      candidate = File.join(parent_directory, child_name)
      return candidate unless File.exist?(candidate) || File.symlink?(candidate)

      # シンボリックリンクをたどった実体が親ディレクトリ外なら拒否
      real_parent = File.realpath(parent_directory)
      real_candidate = File.realpath(candidate)
      ensure_direct_child!(real_candidate, real_parent)
      real_candidate
    rescue Errno::EACCES, Errno::EPERM
      raise
    rescue Errno::ENOENT, Errno::ELOOP
      raise InvalidPathError, 'input path cannot be resolved safely.'
    end

    def output_file_path(file_name, root_directory: ROOT_DIRECTORY, create_directory: false)
      validate_output_file_name!(file_name)

      output_directory = File.join(root_directory, 'output')
      FileUtils.mkdir_p(output_directory) if create_directory && !File.exist?(output_directory)
      output_directory = verified_base_directory(output_directory, root_directory)
      # 従来の拡張子省略形式を維持しつつ，指定済みの場合の二重付与を防止
      output_name = file_name.end_with?('.xlsx') ? file_name : "#{file_name}.xlsx"
      candidate = File.expand_path(output_name, output_directory)
      ensure_direct_child!(candidate, output_directory)
      # 既存のリンクを上書きしてoutput外のファイルへ書き込むことを防止
      raise InvalidPathError, 'output file must not be a symbolic link.' if File.symlink?(candidate)

      candidate
    rescue Errno::EACCES, Errno::EPERM, Errno::EROFS
      raise
    rescue SystemCallError
      raise InvalidPathError, 'output directory cannot be prepared safely.'
    end

    def validate_output_file_name!(file_name)
      raise TypeError, 'file_name must be a String.' unless file_name.is_a?(String)

      # writeは出力先ではなくファイル名だけを受け取るため，パス区切りを許可しない。
      if file_name.empty? || file_name.strip.empty? || file_name != file_name.strip ||
         ['.', '..'].include?(file_name) || file_name.match?(/[\\\/:*?"<>|]/) ||
         file_name.match?(/\A[A-Za-z]:/) || file_name.length > 256
        raise InvalidPathError, 'invalid output file name.'
      end
    end

    private

    # アプリケーションのルートディレクトリに存在するディレクトリであるかを確認
    def verified_base_directory(base_directory, root_directory)
      # 絶対パスへ変換し，存在するディレクトリであることを確認
      expanded_root = File.expand_path(root_directory)
      expanded_base = File.expand_path(base_directory)
      return expanded_base unless File.exist?(expanded_base)

      # ディレクトリであるか否かを確認
      raise InvalidPathError, 'allowed path must be a directory.' unless File.directory?(expanded_base)

      # data/output自体が外部へのリンクに置き換わっている場合も拒否
      real_root = File.realpath(expanded_root)
      real_base = File.realpath(expanded_base)
      ensure_direct_child!(real_base, real_root)
      real_base
    rescue Errno::EACCES, Errno::EPERM
      raise
    rescue Errno::ENOENT, Errno::ELOOP
      raise InvalidPathError, 'allowed directory cannot be resolved safely.'
    end

    # シンボリックリンクの検証
    def ensure_existing_path_is_inside!(candidate, base_directory)
      return unless File.exist?(candidate) || File.symlink?(candidate)

      ensure_direct_child!(File.realpath(candidate), File.realpath(base_directory))
    rescue Errno::EACCES, Errno::EPERM
      raise
    rescue Errno::ENOENT, Errno::ELOOP
      raise InvalidPathError, 'path cannot be resolved safely.'
    end

    # アプリケーションのルートディレクトリ下にあることを確認
    def ensure_direct_child!(candidate, base_directory)
      raise InvalidPathError, 'path is outside the allowed directory.' unless File.dirname(candidate) == base_directory
    end
  end
end
