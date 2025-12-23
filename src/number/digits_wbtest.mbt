///|
test "digits and count_digits" {
  assert_eq(digits(1234), [1, 2, 3, 4])
  assert_eq(digits(0), [0])
  assert_eq(digits(5, b=2, digits=4), [0, 1, 0, 1])
  let counts = count_digits(112233)
  assert_eq(counts.get(1), Some(2))
  assert_eq(counts.get(2), Some(2))
  assert_eq(counts.get(3), Some(2))
}
