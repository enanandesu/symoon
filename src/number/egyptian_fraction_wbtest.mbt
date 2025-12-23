///|
test "egyptian_fraction greedy expansion" {
  assert_eq(egyptian_fraction(3, d=2), [1, 2])
  assert_eq(egyptian_fraction(4, d=13), [4, 18, 468])
  assert_eq(egyptian_fraction(2, d=3), [2, 6])
  assert_eq(egyptian_fraction(5, d=1), [1, 1, 1, 1, 1])
  assert_eq(egyptian_fraction(3, d=2, algorithm="Other").length(), 0)
}
