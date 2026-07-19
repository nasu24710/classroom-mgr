#!/usr/bin/env ruby
# frozen_string_literal: true

# ファイル操作の手動確認用スクリプトです。
#
# SSH 接続を2本使うロック待機テスト:
#   1. 端末Aで次を実行し、対象ファイルを30秒間ロックする。
#      ruby test/manual/file_operation_check.rb hold-lock 'data/<dir>/学年暦/<file>.xlsx' 30
#   2. "Locked:" と表示されたら、端末Bで `bundle exec ruby main.rb` を起動する。
#   3. 端末Bで `read <dir>` を実行する。
#   4. 端末Aの30秒が終わるまで read が待機し、その後に処理されれば成功。
#
# 権限エラーの手動確認:
#   次のようにこのスクリプトからアプリを起動する。
#   ruby test/manual/file_operation_check.rb without-read <対象xlsx> -- bundle exec ruby main.rb
#   起動したアプリで read を実行し、権限エラー後に `>` へ戻ることを確認する。
#   アプリ終了時または Ctrl+C 時に、対象の権限は自動的に元へ戻る。
#
# 既存出力ファイルへの上書き権限エラーの確認:
#   ruby test/manual/file_operation_check.rb without-file-write output/<既存ファイル>.xlsx -- bundle exec ruby main.rb
#   起動したアプリで `write <既存ファイル名（.xlsxなし）>` を実行する。

def usage
  <<~TEXT
    手動テストの種類:
      hold-lock     指定したExcelファイルを指定秒数だけロックし、別プロセスの待機を確認する。
      without-read  指定したExcelファイルの読取権限を一時的に外して、権限エラーを確認する。
      without-file-write 指定した既存Excelファイルの書込権限を一時的に外して、上書き時の権限エラーを確認する。
      without-write 指定したディレクトリの書込権限を一時的に外して、権限エラーを確認する。

    Usage:
      ruby test/manual/file_operation_check.rb hold-lock FILE [SECONDS]
      ruby test/manual/file_operation_check.rb without-read FILE -- COMMAND [ARGUMENT ...]
      ruby test/manual/file_operation_check.rb without-file-write FILE -- COMMAND [ARGUMENT ...]
      ruby test/manual/file_operation_check.rb without-write DIRECTORY -- COMMAND [ARGUMENT ...]

    Examples:
      ruby test/manual/file_operation_check.rb hold-lock data/sample/学年暦/calendar.xlsx 30
      ruby test/manual/file_operation_check.rb without-read data/sample/学年暦/calendar.xlsx -- bundle exec ruby main.rb
      ruby test/manual/file_operation_check.rb without-file-write output/existing.xlsx -- bundle exec ruby main.rb
      ruby test/manual/file_operation_check.rb without-write output -- bundle exec ruby main.rb
  TEXT
end

# 指定パスの権限を一時的に外し、ブロック終了時に必ず元の権限へ戻す。
def with_permission_removed(path, permission_mask)
  original_mode = File.stat(path).mode & 0o7777
  File.chmod(original_mode & ~permission_mask, path)

  yield
ensure
  File.chmod(original_mode, path) if defined?(original_mode)
end

# `--` より後ろのコマンドを、権限変更中に実行する。
def command_after_separator(arguments)
  separator_index = arguments.index('--')
  abort usage if separator_index.nil? || separator_index == arguments.length - 1

  arguments[(separator_index + 1)..]
end

def ensure_unix_permission_test!
  if Gem.win_platform?
    abort <<~TEXT
      without-read / without-write は Linux の chmod による権限テスト用です。
      Windows では ACL が使われるため、このスクリプトでは権限拒否を再現できません。
      SSH 接続先の Linux サーバで実行してください。
    TEXT
  end

  return unless wsl_windows_drive?

  abort <<~TEXT
    /mnt/c などの Windows 側ドライブ上の WSL では、chmod による権限拒否を再現できません。
    SSH 接続先の Linux サーバ、または WSL のホームディレクトリ（~/...）へ移したコピーで実行してください。
  TEXT
end

def wsl_windows_drive?
  return false unless File.exist?('/proc/version')
  return false unless File.read('/proc/version').downcase.include?('microsoft')

  Dir.pwd.match?(%r{\A/mnt/[a-z]/}i)
end

begin
case ARGV.first
when 'hold-lock'
  # 指定ファイルと同じ場所にある .lock ファイルをロックする。
  # この間に別の端末から同じファイルを read すると、ロック解除まで待機する。
  file_path = ARGV[1]
  seconds = Integer(ARGV.fetch(2, 30))
  abort usage unless File.file?(file_path)

  File.open("#{file_path}.lock", 'a+b') do |lock_file|
    begin
      lock_file.flock(File::LOCK_EX)
      puts "Locked: #{file_path} (#{seconds} seconds)"
      sleep seconds
    ensure
      lock_file.flock(File::LOCK_UN)
    end
  end
when 'without-read'
  # 指定Excelの読取権限を外した状態でアプリを起動する。
  # 起動後に read を実行し、権限エラーと `>` への復帰を確認する。
  ensure_unix_permission_test!
  file_path = ARGV[1]
  abort usage unless File.file?(file_path)

  with_permission_removed(file_path, 0o444) do
    puts "Read permission removed temporarily: #{file_path}"
    system(*command_after_separator(ARGV.drop(2)))
  end
when 'without-write'
  # 指定ディレクトリの書込権限を外した状態でアプリを起動する。
  # output を指定した場合、未使用名で write を実行して権限エラーを確認する。
  ensure_unix_permission_test!
  directory_path = ARGV[1]
  abort usage unless Dir.exist?(directory_path)

  with_permission_removed(directory_path, 0o222) do
    puts "Write permission removed temporarily: #{directory_path}"
    system(*command_after_separator(ARGV.drop(2)))
  end
when 'without-file-write'
  # 既存Excelの書込権限を外した状態でアプリを起動する。
  # 起動後に同じファイル名で write を実行し、上書き時の権限エラーを確認する。
  ensure_unix_permission_test!
  file_path = ARGV[1]
  abort usage unless File.file?(file_path)

  with_permission_removed(file_path, 0o222) do
    puts "Write permission removed temporarily: #{file_path}"
    system(*command_after_separator(ARGV.drop(2)))
  end
else
  abort usage
end
rescue Interrupt
  warn "\n手動テストを中断しました。変更していた権限は復元済みです。"
  exit 130
end
