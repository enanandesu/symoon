///|
test "limit reciprocal directions" {
  let x = sym("x")
  let expr = div(int(1), sub(x, int(1)))
  inspect(limit(expr, "x", int(1)), content="Divergent")
  inspect(limit_left(expr, "x", int(1)), content="NegInf")
  inspect(limit_right(expr, "x", int(1)), content="PosInf")
}

///|
test "limit mirrored difference directions" {
  let x = sym("x")
  let expr = div(int(2), sub(int(3), x))
  inspect(limit_left(expr, "x", int(3)), content="PosInf")
  inspect(limit_right(expr, "x", int(3)), content="NegInf")
}
