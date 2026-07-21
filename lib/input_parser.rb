require 'optparse'
require_relative 'parsed_input'
require_relative 'error_handler'

class InputParser
    # 入力を分割した後もクォーテーションで囲まれていたかを保持するための構造体
    Token = Struct.new(:value, :quoted, keyword_init: true)

    # コマンド名の定義
    COMMAND_NAMES = [
        "read",
        "select",
        "create",
        "print",
        "write",
        "quit"
    ].freeze

    # コマンドごとの引数の個数を定義
    COMMAND_ARGUMENT_COUNTS = {
        "read" => 1,
        "select" => 0,
        "create" => 0,
        "print" => 0,
        "write" => 1,
        "quit" => 0
    }.freeze

    # クォーテーション付きの「-」始まりの値をOptionParserにオプションと誤認させないための一時文字列
    QUOTED_TOKEN_PREFIX = "__input_parser_quoted_token_".freeze

    def self.parse(input)
        # (1) inputが文字列であるか確認する
        unless input.is_a?(String)
            raise TypeError, "input must be a String"
        end

        option_parser = OptionParser.new # (2) OptionParserインスタンスを生成
        begin
            # (3) クォーテーション情報を保持して分割
            parsed_tokens = split_with_quote_information(input)
        rescue ArgumentError
            # クォーテーションの閉じ忘れなど，入力文字列として解析できない場合
            return ErrorHandler::ERROR_UNKNOWN_COMMAND # TODO: エラー番号を追加し，変更
        end
        command_name = parsed_tokens.shift&.value # (4) 先頭要素からコマンド名を取得
        options = {}

        # (4) コマンド名が有効かどうか確認
        unless COMMAND_NAMES.include?(command_name)
            return ErrorHandler::ERROR_UNKNOWN_COMMAND
        end

        # OptionParserは「-subject」を「-s ubject」と解釈
        # 「-」から始まる文字列の長さが2以上かつクォーテーションで囲まれていない場合はエラーとする
        if parsed_tokens.any? { |token| !token.quoted && token.value.start_with?("-") && !token.value.start_with?("--") && token.value.length > 2 }
            return ErrorHandler::ERROR_UNKNOWN_OPTION
        end

        # (5) コマンドに応じてオプションを登録
        register_options(option_parser, command_name, options)

        # 引用符付きの「-」始まりの値だけを一時的に置換
        # 例: read "-2026" の -2026 をOptionParserにオプション扱いしない
        quoted_token_values = {}
        tokens = parsed_tokens.each_with_index.map do |token, index|
            if token.quoted && token.value.start_with?("-")
                placeholder = "#{QUOTED_TOKEN_PREFIX}#{index}__"
                quoted_token_values[placeholder] = token.value
                placeholder
            else
                token.value
            end
        end

        # (6) オプションを解析
        begin
            option_parser.parse!(tokens)
        rescue OptionParser::InvalidOption
            return ErrorHandler::ERROR_UNKNOWN_OPTION
        rescue OptionParser::MissingArgument
            return ErrorHandler::ERROR_UNKNOWN_OPTION
        end

        # OptionParserで解析した後，プレースホルダーを利用者が入力した値に戻す。
        restore_quoted_token_values!(tokens, quoted_token_values)
        restore_quoted_token_values!(options, quoted_token_values)

        # 引数の個数を確認し，不足または超過している場合はエラー番号を返却
        arguments = tokens
        unless arguments.length == COMMAND_ARGUMENT_COUNTS[command_name]
            if arguments.length == 0
                if command_name == "read"
                    return ErrorHandler::ERROR_DIRECTORY_NOT_SPECIFIED
                end
                if command_name == "write"
                    return ErrorHandler::ERROR_OUTPUT_FILE_NOT_SPECIFIED
                end
            else
                return ErrorHandler::ERROR_INVALID_ARGUMENT_MESSAGE
            end
        end

        # トークンの分類と個数確認後，値付きオプションと位置引数の実値を検証
        # 半角スペースだけの値は許容し，空文字やタブ・改行だけの値は無効とする
        if options.values.any? { |value| blank_value?(value) }
            return ErrorHandler::ERROR_UNKNOWN_OPTION
        end

        if arguments.any? { |argument| blank_value?(argument) }
            if command_name == "read"
                return ErrorHandler::ERROR_DIRECTORY_NOT_SPECIFIED
            end
            if command_name == "write"
                return ErrorHandler::ERROR_OUTPUT_FILE_NOT_SPECIFIED
            end
            return ErrorHandler::ERROR_UNKNOWN_COMMAND
        end

        # (7) ParsedInputインスタンスを生成して返却
        ParsedInput.new(command_name: command_name, options: options, arguments: arguments)
    end

    # 空白，ダブルクォート，シングルクォートを考慮して入力文字列を分割
    def self.split_with_quote_information(input)
        tokens = []
        current_token = +""
        current_quote = nil
        token_started = false
        token_quoted = false

        input.each_char do |char|
            if current_quote
                # クォーテーション内では空白も通常文字として扱い，同じクォーテーションが来たらクォーテーションを終了
                if char == current_quote
                    current_quote = nil
                else
                    current_token << char
                end
            elsif char == '"' || char == "'"
                # クォーテーションの開始。read "" のような空文字列もトークンとして扱う
                current_quote = char
                token_started = true
                token_quoted = true
            elsif char.match?(/\s/)
                # クォーテーションの外側の空白はトークン区切りとして扱う
                if token_started
                    tokens << Token.new(value: current_token, quoted: token_quoted)
                    current_token = +""
                    token_started = false
                    token_quoted = false
                end
            else
                current_token << char
                token_started = true
            end
        end

        # クォーテーションが閉じていない場合は，エラーとしてArgumentErrorを発生させる
        raise ArgumentError, "Unclosed quote in input" if current_quote

        tokens << Token.new(value: current_token, quoted: token_quoted) if token_started
        tokens
    end

    # OptionParserに渡す前に置き換えた一時文字列を，元のクォーテーション付きトークン値に戻す
    def self.restore_quoted_token_values!(target, quoted_token_values)
        case target
        when Array
            target.map! { |value| quoted_token_values.fetch(value, value) }
        when Hash
            target.each do |key, value|
                target[key] = quoted_token_values.fetch(value, value)
            end
        end
    end

    # nil，空文字，またはタブや改行などだけで構成された値かを判定
    def self.blank_value?(value)
        return true if value.nil? || value.empty?

        value.match?(/\A[ \t\r\n\v\f]*[\t\r\n\v\f][ \t\r\n\v\f]*\z/)
    end

    # オプション引数を登録するメソッド
    def self.register_options(option_parser, command_name, options)
        case command_name
        when "create"
            option_parser.on("-t TERM", "--term TERM") do |term|
                raise OptionParser::InvalidOption if options.key?(:term)
                options[:term] = term
            end
        when "print"
            option_parser.on("-d DATE", "--date DATE") do |date|
                raise OptionParser::InvalidOption if options.key?(:date)
                options[:date] = date
            end

            option_parser.on("-s SUBJECT", "--subject SUBJECT") do |subject|
                raise OptionParser::InvalidOption if options.key?(:subject)
                options[:subject] = subject
            end
        end
    end

    private_constant :Token
    private_class_method :split_with_quote_information
    private_class_method :restore_quoted_token_values!
    private_class_method :blank_value?
    private_class_method :register_options
end
