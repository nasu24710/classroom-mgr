# Repository Test Cases

## `academic_calendar_information_repository_unit_test.rb`

- Initialize repository with preloaded records
- `find_all` returns stored records
- `find_all` returns a copy, not the internal array
- `replace_all` replaces contents
- `replace_all` with an empty array
- `find_by_day_of_the_week` returns matching record(s)
- `find_by_day_of_the_week` with multiple matches
- `find_by_day_of_the_week` with no matches
- `find_by_day_of_the_week` rejects non-`Symbol` input
- Constructor rejects non-array input

## `lecture_room_management_information_repository_unit_test.rb`

- Initialize repository with preloaded records
- `find_all` returns stored records
- `find_all` returns a copy, not the internal array
- `add`, `remove`, and `replace_all` work together
- `replace_all` with an empty array
- `find_by_date_and_lecture_room_name` returns matching record(s)
- `find_by_date_and_lecture_room_name` with multiple matches
- `find_by_date_and_lecture_room_name` with no matches
- `find_by_date_and_lecture_room_name` rejects invalid `date`
- `find_by_date_and_lecture_room_name` rejects invalid `lecture_room_name`
- Constructor rejects non-array input
- `add` / `remove` reject invalid types

## `managed_lecture_room_information_repository_unit_test.rb`

- Initialize repository with preloaded records
- `find_all` returns stored records
- `find_all` returns a copy, not the internal array
- `add`, `remove`, and `replace_all` work together
- `replace_all` with an empty array
- Constructor rejects non-array input
- `add` / `remove` reject invalid types

## `reservation_information_repository_unit_test.rb`

- Initialize repository with preloaded records
- `find_all` returns stored records
- `find_all` returns a copy, not the internal array
- `add`, `remove`, and `replace_all` work together
- `replace_all` with an empty array
- Constructor rejects non-array input
- `add` / `remove` reject invalid types

## `timetable_information_repository_unit_test.rb`

- Initialize repository with preloaded records
- `find_all` returns stored records
- `find_all` returns a copy, not the internal array
- `add`, `remove`, and `replace_all` work together
- `replace_all` with an empty array
- Constructor rejects non-array input
- `add` / `remove` reject invalid types
