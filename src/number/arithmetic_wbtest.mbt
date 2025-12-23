///|
test "nt_gcd and nt_lcm handle common cases" {
  assert_eq(nt_gcd(54, 24), 6)
  assert_eq(nt_gcd(-54, 24), 6)
  assert_eq(nt_lcm(6, 8), 24)
  assert_eq(nt_lcm(0, 5), 0)
}

///|
test "gcd/lcm aliases match nt_ versions" {
  assert_eq(gcd(12, 18), 6)
  assert_eq(lcm(12, 18), 36)
  assert_eq(igcd(12, 18), 6)
  assert_eq(ilcm(12, 18), 36)
}

///|
test "nt_gcd_ex finds Bezout coefficients" {
  let (x, y, g) = nt_gcd_ex(12, 18)
  assert_eq((x, y, g), (-1, 1, 6))
  let (x2, y2, g2) = nt_gcd_ex(0, 5)
  assert_eq((x2, y2, g2), (0, 1, 5))
  let (x3, y3, g3) = nt_gcd_ex(-10, 15)
  assert_eq(-10 * x3 + 15 * y3, g3)
  assert_eq(g3, 5)
}

///|
test "gcdex alias matches nt_gcd_ex" {
  let (x, y, g) = gcdex(12, 18)
  assert_eq((x, y, g), (-1, 1, 6))
}
