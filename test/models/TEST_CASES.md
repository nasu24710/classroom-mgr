# Model Test Cases

## `day_attribute_unit_test.rb`

- Valid initialization with all fields set to expected values
- Valid initialization with a populated `comments` array
- Valid initialization with an empty `comments` array
- Valid initialization with `comments: nil`
- Invalid `day_of_the_week_changes` type
- Invalid `is_makeup_class` type
- Invalid `is_exam_period` type
- Invalid `is_public_holiday` type
- Invalid `is_holiday` type
- Invalid `comments` type
- Invalid `comments` contents

## `academic_calendar_information_unit_test.rb`

- Valid initialization
- Boundary `term` values (`0`, negative integer)
- Invalid `date` type
- Invalid `day_of_the_week` type
- Invalid `term` type
- Invalid `day_attribute` type
- Invalid `day_attribute: nil`

## `lecture_room_management_information_unit_test.rb`

- Valid initialization
- Valid initialization with empty `periods` and empty `comment`
- Invalid `date` type
- Invalid `day_of_the_week` type
- Invalid `term` type
- Invalid `periods` type
- Invalid `room_name` type
- Invalid `subject` type
- Invalid `user` type
- Invalid `comment` type
- `conflicting_periods_with` returns overlap
- `conflicting_periods_with` returns empty array for no overlap
- `conflicting_periods_with` returns full overlap for identical periods
- `conflicting_periods_with` rejects invalid argument type

## `managed_lecture_room_information_unit_test.rb`

- Valid initialization
- Valid initialization with empty `room_name`
- Invalid `room_name` type

## `reservation_information_unit_test.rb`

- Valid initialization
- Valid initialization with empty `subject`, empty `periods`, empty `user`, empty `room_names`
- Invalid `date` type
- Invalid `subject` type
- Invalid `periods` type
- Invalid `user` type
- Invalid `room_names` type
- Invalid `room_names` contents
- Defensive copy of input arrays

## `timetable_information_unit_test.rb`

- Valid initialization
- Valid initialization with empty `subject`, empty `periods`, empty `user`, empty `room_names`
- Invalid `subject` type
- Invalid `term` type
- Invalid `day_of_the_week` type
- Invalid `periods` type
- Invalid `user` type
- Invalid `room_names` type
- Invalid `room_names` contents
- Defensive copy of input arrays
