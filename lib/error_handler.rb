# frozen_string_literal: true

class ErrorHandler
  ERROR_UNKNOWN_COMMAND = 1
  ERROR_ACADEMIC_CALENDAR_FILE_NOT_FOUND = 2
  ERROR_ACADEMIC_CALENDAR_PARSE_FAILED = 3
  ERROR_TIMETABLE_FILE_NOT_FOUND = 4
  ERROR_TIMETABLE_PARSE_FAILED = 5
  ERROR_RESERVATION_FILE_NOT_FOUND = 6
  ERROR_RESERVATION_PARSE_FAILED = 7
  ERROR_DIRECTORY_NOT_SPECIFIED = 8
  ERROR_MANAGED_LECTURE_ROOM_FILE_NOT_FOUND = 9
  ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED = 10
  ERROR_MANAGED_LECTURE_ROOM_NOT_LOADED = 11
  ERROR_ACADEMIC_CALENDAR_NOT_LOADED = 12
  ERROR_TIMETABLE_NOT_LOADED = 13
  ERROR_RESERVATION_NOT_LOADED = 14
  ERROR_UNKNOWN_OPTION = 15
  ERROR_LECTURE_ROOM_MANAGEMENT_INFORMATION_NOT_FOUND = 16
  ERROR_OUTPUT_FILE_NOT_SPECIFIED = 17
  ERROR_MANAGED_LECTURE_ROOM_NOT_SELECTED = 18
  ERROR_ACADEMIC_CALENDAR_LOAD_FAILED = 19
  ERROR_TIMETABLE_LOAD_FAILED = 20
  ERROR_RESERVATION_LOAD_FAILED = 21
  ERROR_INVALID_DATE_FORMAT = 22
  ERROR_RESERVATION_DATE_NOT_FOUND_IN_ACADEMIC_CALENDAR = 23
  ERROR_INVALID_FILENAME_CHARACTER = 24
  ERROR_FILENAME_TOO_LONG = 25
  ERROR_INVALID_ARGUMENT_MESSAGE = 26
  ERROR_MULTIPLE_ACADEMIC_CALENDAR_FILES_MESSAGE = 27
  ERROR_MULTIPLE_RESERVATION_FILES_MESSAGE = 28
  ERROR_MULTIPLE_TIMETABLE_FILES_MESSAGE = 29
  ERROR_MULTIPLE_MANAGED_LECTURE_ROOM_FILES_MESSAGE = 30
  ERROR_OUTPUT_FILE_NOT_SPECIFIED_MESSAGE = 31
  ERROR_FILE_OPERATION_PERMISSION_DENIED = 32
  ERROR_PATH_OUTSIDE_ALLOWED_DIRECTORY = 33
  ERROR_MULTIPLE_EXCEL_FILES = 34

  # コマンド処理が返すエラー番号と，画面に表示するエラーメッセージを対応づける。
  NUMBER_TO_ERROR_SENTENCE = {
    ERROR_UNKNOWN_COMMAND => "エラー: 無効なコマンドです．\nマニュアルを参照し，有効なコマンドを入力してください．",
    ERROR_ACADEMIC_CALENDAR_FILE_NOT_FOUND => "エラー：学年暦データが見つかりません．\n学年暦データを「学年暦/ 」ディレクトリにアップロードしてください．",
    ERROR_ACADEMIC_CALENDAR_PARSE_FAILED => "エラー：学年暦データが読み込めません．\nファイル形式，または内容を確認してください．",
    ERROR_TIMETABLE_FILE_NOT_FOUND => "エラー：時間割データが見つかりません．\n時間割データを「時間割/ 」ディレクトリにアップロードしてください．",
    ERROR_TIMETABLE_PARSE_FAILED => "エラー：時間割データが読み込めません．\nファイル形式，または内容を確認してください．",
    ERROR_RESERVATION_FILE_NOT_FOUND => "エラー：予約データが見つかりません．\n予約データを「予約/ 」ディレクトリにアップロードしてください．",
    ERROR_RESERVATION_PARSE_FAILED => "エラー：予約データが読み込めません．\nファイル形式，または内容を確認してください．",
    ERROR_DIRECTORY_NOT_SPECIFIED => "エラー：ディレクトリ名が指定されていません．\nデータをアップロードしたディレクトリ名を入力してください．",
    ERROR_MANAGED_LECTURE_ROOM_FILE_NOT_FOUND => "エラー：管理対象講義室データが見つかりません．\n管理対象講義室データを「data/管理対象講義室/ 」ディレクトリにアップロードしてください．",
    ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED => "エラー：管理対象講義室データの内容が正しくありません．\n「data/管理対象講義室/ 」にある管理対象講義室データを確認してください．",
    ERROR_MANAGED_LECTURE_ROOM_NOT_LOADED => "エラー：管理対象講義室データが読み込まれていません．\n「select 」コマンドを実行してください．",
    ERROR_ACADEMIC_CALENDAR_NOT_LOADED => "エラー：学年暦データが読み込まれていません．\n「read 」コマンドを実行してください．",
    ERROR_TIMETABLE_NOT_LOADED => "エラー：時間割データが読み込まれていません．\n「read 」コマンドを実行してください．",
    ERROR_RESERVATION_NOT_LOADED => "エラー：予約データが読み込まれていません．\n「read 」コマンドを実行してください．",
    ERROR_UNKNOWN_OPTION => "エラー：無効なオプションです．\nマニュアルを参照し，有効なオプションを入力してください．",
    ERROR_LECTURE_ROOM_MANAGEMENT_INFORMATION_NOT_FOUND => "エラー: 講義室管理情報が見つかりません．\n「create 」コマンドを実行してください．",
    ERROR_OUTPUT_FILE_NOT_SPECIFIED => "エラー: 講義室管理一覧表のファイル名を指定してください．",
    ERROR_MANAGED_LECTURE_ROOM_NOT_SELECTED => "エラー：管理対象講義室は設定されませんでした．\n管理対象講義室データを確認し，内容を更新してください．",
    ERROR_ACADEMIC_CALENDAR_LOAD_FAILED => "エラー：学年暦データの読み込みに失敗しました．",
    ERROR_TIMETABLE_LOAD_FAILED => "エラー：時間割データの読み込みに失敗しました．",
    ERROR_RESERVATION_LOAD_FAILED => "エラー：予約データの読み込みに失敗しました．",
    ERROR_INVALID_DATE_FORMAT => "エラー：日付の形式が正しくありません．\n有効な日付を入力してください．",
    ERROR_RESERVATION_DATE_NOT_FOUND_IN_ACADEMIC_CALENDAR => "エラー：予約データの日付に対応する学年暦データが見つかりません．\n予約データと学年暦データの日付を確認してください．",
    ERROR_INVALID_FILENAME_CHARACTER => "エラー：講義室一覧表のファイル名に不正な文字が含まれています．",
    ERROR_FILENAME_TOO_LONG => "エラー：講義室管理一覧表のファイル名が上限文字数(256文字)を超えています．",
    ERROR_INVALID_ARGUMENT_MESSAGE => "エラー：無効な引数です．\nマニュアルを参照し，有効な引数を入力してください．",
    ERROR_MULTIPLE_ACADEMIC_CALENDAR_FILES_MESSAGE => "エラー：学年暦データが2つ以上あります．\n「2026/学年暦/ 」ディレクトリには，学年暦データを1つだけ配置してください．",
    ERROR_MULTIPLE_RESERVATION_FILES_MESSAGE => "エラー：予約データが2つ以上あります．\n「2026/予約/ 」ディレクトリには，予約データを1つだけ配置してください．",
    ERROR_MULTIPLE_TIMETABLE_FILES_MESSAGE => "エラー：時間割データが2つ以上あります．\n「2026/時間割/ 」ディレクトリには，時間割データを1つだけ配置してください．",
    ERROR_MULTIPLE_MANAGED_LECTURE_ROOM_FILES_MESSAGE =>"エラー：管理対象講義室データが2つ以上あります．\n「data/管理対象講義室/ 」ディレクトリには，管理対象講義室データを1つだけ配置してください．",
    ERROR_OUTPUT_FILE_NOT_SPECIFIED_MESSAGE => "エラー：講義室管理一覧表のファイル名を指定してください．",
    ERROR_FILE_OPERATION_PERMISSION_DENIED => "エラー：ファイルを操作する権限がありません．\nデータおよび出力先ディレクトリの権限を確認してください．",
    ERROR_PATH_OUTSIDE_ALLOWED_DIRECTORY => "エラー：指定されたパスは，許可されたディレクトリの範囲外です．",
    ERROR_MULTIPLE_EXCEL_FILES => "エラー：対象ディレクトリに複数のファイルが存在します．\nファイルを1つだけ配置してください．",
  }.freeze

  def self.print_error(error_number)
    # エラー番号からメッセージを取り出し，利用者に表示する。
    raise TypeError, "error_number must be an Integer" unless error_number.is_a?(Integer)

    error_sentence = find_error(error_number)
    raise KeyError, "undefined error number: #{error_number}" if error_sentence.nil?

    puts error_sentence
  end

  def self.find_error(error_number)
    # エラー番号に対応するメッセージだけを返す。表示は呼び出し元に任せる。
    raise TypeError, "error_number must be an Integer" unless error_number.is_a?(Integer)

    NUMBER_TO_ERROR_SENTENCE[error_number]
  end
end
