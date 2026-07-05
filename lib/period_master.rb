class PeriodMaster
  SEQUENCE = [
    :p1,
    :p2,
    :p3,
    :p4,
    :lunch,
    :p5,
    :p6,
    :p7,
    :p8
  ].freeze

  ORDER = {
    p1: 1,
    p2: 2,
    p3: 3,
    p4: 4,
    lunch: 5,
    p5: 6,
    p6: 7,
    p7: 8,
    p8: 9
  }.freeze

  SYMBOL_TO_STRING = {
    p1: '1',
    p2: '2',
    p3: '3',
    p4: '4',
    lunch: '昼休み',
    p5: '5',
    p6: '6',
    p7: '7',
    p8: '8'
  }.freeze
end
