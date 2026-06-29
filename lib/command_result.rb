# frozen_string_literal: true

class CommandResult
  # 呼び出し元が実行結果を確認できるように，終了フラグ・成功可否・エラー番号を公開する。
  attr_reader :exit_flag, :is_succeed, :error_number

  def initialize(exit_flag, is_succeed, error_number)
    # 結果オブジェクトとして不正な値を保持しないよう，生成時に型を確認する。
    raise TypeError, "exit_flag must be true or false" unless exit_flag == true || exit_flag == false
    raise TypeError, "is_succeed must be true or false" unless is_succeed == true || is_succeed == false
    raise TypeError, "error_number must be an Integer" unless error_number.is_a?(Integer)

    @exit_flag = exit_flag
    @is_succeed = is_succeed
    @error_number = error_number
  end
end
