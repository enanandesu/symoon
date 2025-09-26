///|
test "show prints constants and symbols" {
  assert_eq(int(42).to_string(), "42")
  assert_eq(double(3.5).to_string(), "3.5")
  assert_eq(sym("x").to_string(), "x")
}

///|
test "show respects operator precedence" {
  let expr = add(sym("x"), mul(sym("y"), sym("z")))
  assert_eq(expr.to_string(), "x + y * z")
}

///|
test "show formats unary operations" {
  let expr = neg(add(sym("x"), sym("y")))
  assert_eq(expr.to_string(), "-(x + y)")
  let sin_expr = sin(sym("theta"))
  assert_eq(sin_expr.to_string(), "sin(theta)")
}

///|
test "show adds parentheses for powers" {
  let expr = pow(add(sym("x"), sym("y")), int(2))
  assert_eq(expr.to_string(), "(x + y) ^ 2")
}

///|
test "show more complicated expressions" {
  let x = sym("x")
  let y = sym("y")
  let expr = pow(x, int(3) + double(4.1) + y) *
    int(2) *
    y /
    (int(1) + pow(y, int(4)))
  inspect(expr, content="(x ^ (3 + 4.1 + y) * 2 * y) / (1 + y ^ 4)")
  inspect(simplify(expr), content="(x ^ (7.1 + y) * 2 * y) / (1 + y ^ 4)")
  let expr2 = -(x + y + int(3) * x) * (x - y) / log(x + y) * sin(x / y)
  inspect(
    expr2,
    content="(-(x + y + 3 * x) * (x - y)) / ln(x + y) * sin(x / y)",
  )
  inspect(
    simplify(expr2),
    content="(-(4 * x + y) * (x - y)) / ln(x + y) * sin(x / y)",
  )
  let expr3 = -(-x)
  inspect(expr3, content="-(-x)")
}
