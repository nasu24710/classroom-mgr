# Interactive Menu Test Cases

## `interactive_menu_unit_test.rb`

- `new` creates an `InteractiveMenu` instance
- `ask_yes_or_no` returns `true` for `yes`
- `ask_yes_or_no` returns `false` for `no`
- `ask_yes_or_no` rejects invalid `message` type
- `select_from_list` returns the selected option index
- `select_from_list` forwards prompt choices correctly
- `select_from_list` rejects invalid `message` type
- `select_from_list` rejects invalid `options` type
- `select_from_list` rejects invalid `options` contents

## `manual_check.rb`

- Manual-only check for `InteractiveMenu`
- Run it directly with `ruby test/interactive_menu/manual_check.rb`
- This file is not included in the automatic test suite because its name does not end with `_test.rb`
