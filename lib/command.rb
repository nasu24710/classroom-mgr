# frozen_string_literal: true

require_relative "command_result"
require_relative "error_handler"

class Command
  # コマンドが正常終了したときに返す共通の成功コード。
  SUCCESS = 0

  def execute
    # コマンド固有の処理とCommandResultの返却は，各サブクラスのexecuteで実装する。
    raise NotImplementedError
  end
end
