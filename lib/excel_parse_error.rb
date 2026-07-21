class ExcelParseError < StandardError
  attr_reader :sheet, :row, :col

  def initialize(message, sheet: nil, row: nil, col: nil)
    @sheet = sheet
    @row = row
    @col = col

    location = [
      sheet && "sheet「#{sheet}」",
      col && "#{column_index_to_letter(col)}",
      row && "#{row + 1}"
    ].compact.join

    full_message = location.empty? ? message : "#{location}: #{message}"
    super(full_message)
  end

  private

  # 0始まりの列インデックスをExcelの列名(A, B, ..., Z, AA, AB, ...)に変換する
  def column_index_to_letter(index)
    letter = ''
    n = index
    loop do
      letter = (n % 26 + 65).chr + letter
      n = n / 26 - 1
      break if n < 0
    end
    letter
  end
end
