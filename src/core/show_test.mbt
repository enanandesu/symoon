///|
test "show prints constants and symbols" {
  inspect(int(42), content="42")
  inspect(double(3.5), content="3.5")
  inspect(sym("x"), content="x")
}

///|
test "show respects operator precedence" {
  let expr = add(sym("x"), mul(sym("y"), sym("z")))
  inspect(expr, content="x + y * z")
}

///|
test "show formats unary operations" {
  inspect(neg(add(sym("x"), sym("y"))), content="-(x + y)")
  inspect(sin(sym("theta")), content="sin(theta)")
}

///|
test "show formats extended trig operations" {
  inspect(tan(sym("x")), content="tan(x)")
  inspect(asin(sym("x")), content="asin(x)")
  inspect(acos(sym("x")), content="acos(x)")
  inspect(atan(sym("x")), content="atan(x)")
  inspect(sinh(sym("x")), content="sinh(x)")
  inspect(cosh(sym("x")), content="cosh(x)")
  inspect(tanh(sym("x")), content="tanh(x)")
  inspect(asinh(sym("x")), content="asinh(x)")
  inspect(acosh(sym("x")), content="acosh(x)")
  inspect(atanh(sym("x")), content="atanh(x)")
  inspect(abs(sym("x")), content="abs(x)")
}

///|
test "show formats function calls" {
  let fallback = differentiate(tan(sym("x")), "y")
  inspect(fallback, content="1 / cos(x) ^ 2 * 0")
}

///|
test "show adds parentheses for powers" {
  inspect(pow(add(sym("x"), sym("y")), int(2)), content="(x + y) ^ 2")
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
  inspect(simplify(expr), content="(2 * y * x ^ (7.1 + y)) / (1 + y ^ 4)")
  let expr2 = -(x + y + int(3) * x) * (x - y) / log(x + y) * sin(x / y)
  inspect(
    expr2,
    content="(-(x + y + 3 * x) * (x - y)) / log(x + y) * sin(x / y)",
  )
  inspect(
    simplify(expr2),
    content="-((4 * x + y) * (x - y) * sin(x / y)) / log(x + y)",
  )
  let expr3 = -(-x)
  inspect(expr3, content="-(-x)")
}

///|
test "to_latex formats expressions" {
  let x = sym("x")
  let y = sym("y")
  assert_eq(to_latex(x), "x")
  assert_eq(to_latex(neg(x + y)), "-\\left(x + y\\right)")
  let frac_expr = div(sin(x), y)
  assert_eq(to_latex(frac_expr), "\\frac{\\sin\\left(x\\right)}{y}")
  let pow_expr = pow(x + y, int(2))
  assert_eq(to_latex(pow_expr), "\\left(x + y\\right)^{2}")
  assert_eq(to_latex(abs(x)), "\\left|x\\right|")
}
