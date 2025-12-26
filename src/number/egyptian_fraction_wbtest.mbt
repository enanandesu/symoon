///|
test "egyptian_fraction greedy expansion" {
  assert_eq(egyptian_fraction(3, d=2), [1, 2])
  assert_eq(egyptian_fraction(4, d=13), [4, 18, 468])
  assert_eq(egyptian_fraction(2, d=3), [2, 6])
  assert_eq(egyptian_fraction(5, d=1), [1, 1, 1, 1, 1])
  assert_eq(egyptian_fraction(3, d=2, algorithm="Other").length(), 0)
}

///|
test "egyptian_fraction handles edge cases" {
  assert_eq(egyptian_fraction(0, d=5).length(), 0)
  assert_eq(egyptian_fraction(3, d=0).length(), 0)
  assert_eq(egyptian_fraction(7, d=3), [1, 1, 3])
}
