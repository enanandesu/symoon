///|
test "nt_is_divisible_by covers zero and negatives" {
  assert_eq(nt_is_divisible_by(10, 2), true)
  assert_eq(nt_is_divisible_by(10, 3), false)
  assert_eq(nt_is_divisible_by(0, 5), true)
  assert_eq(nt_is_divisible_by(5, 0), false)
  assert_eq(nt_is_divisible_by(-12, 3), true)
  assert_eq(nt_is_divisible_by(12, -3), true)
}

///|
test "nt_is_divisible_by_all_and_any handle collections" {
  assert_eq(nt_is_divisible_by_all(60, [2, 3, 5]), true)
  assert_eq(nt_is_divisible_by_all(12, [2, 5]), false)
  assert_eq(nt_is_divisible_by_all(10, []), true)
  assert_eq(nt_is_divisible_by_any(14, [3, 5, 7]), true)
  assert_eq(nt_is_divisible_by_any(25, [2, 4]), false)
  assert_eq(nt_is_divisible_by_any(10, []), false)
}

///|
test "nt_is_divisible_by works with negatives in collections" {
  assert_eq(nt_is_divisible_by_all(-30, [2, 3, 5]), true)
  assert_eq(nt_is_divisible_by_any(0, [2, 3]), true)
  assert_eq(nt_is_divisible_by_any(-25, [6, 7]), false)
}
