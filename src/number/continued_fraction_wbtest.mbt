///|
test "continued fraction helpers" {
  let cf = continued_fraction_iterator(3, d=8)
  assert_eq(cf, [0, 2, 1, 2])
  let neg = continued_fraction_iterator(-3, d=8)
  assert_eq(neg, [-1, 1, 1, 1, 2])
  let (pre, period) = continued_fraction_periodic(3, 2, d=7)
  assert_eq(pre, [2])
  assert_eq(period, [1, 4, 1, 1])
  let (p2, per2) = continued_fraction_periodic(0, 1, d=2)
  assert_eq(p2, [1])
  assert_eq(per2, [2])
  let conv = continued_fraction_convergents([0, 2, 1, 2])
  assert_eq(conv, [(0, 1), (1, 2), (1, 3), (3, 8)])
  let reduced = continued_fraction_reduce([0, 2, 1, 2])
  assert_eq(reduced, (3, 8))
}
