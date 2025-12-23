///|
test "linear diophantine solver returns parametric form" {
  let (x0, y0, sx, sy) = diophantine_linear(2, 3, 10)
  assert_eq(2 * x0 + 3 * y0, 10)
  let x = x0 + sx
  let y = y0 + sy
  assert_eq(2 * x + 3 * y, 10)
}

///|
test "pell solutions generate first terms for d=2" {
  let sols = pell_solutions(2, count=3)
  assert_eq(sols, [(3, 2), (17, 12), (99, 70)])
  for pair in sols {
    let (x, y) = pair
    assert_eq(x * x - 2 * y * y, 1)
  }
  let none = pell_solutions(4, count=3)
  assert_eq(none.length(), 0)
}

///|
test "pythagorean triples generator yields primitive triples" {
  let triples = pythagorean_triples(2)
  assert_eq(triples.length(), 2)
  assert_eq(triples[0], (3, 4, 5))
  assert_eq(triples[1], (5, 12, 13))
}
