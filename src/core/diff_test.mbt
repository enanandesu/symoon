///|
test "differentiate constants and symbols" {
  assert_eq(differentiate(int(5), "x"), int(0))
  assert_eq(differentiate(double(3.14), "x"), int(0))
  assert_eq(differentiate(sym("x"), "x"), int(1))
  assert_eq(differentiate(sym("y"), "x"), int(0))
}

///|
test "differentiate unary operations" {
  let x = sym("x")
  inspect(simplify(differentiate(sin(x), "x")), content="cos(x)")
  inspect(simplify(differentiate(cos(x), "x")), content="-(sin(x))")
  inspect(simplify(differentiate(tan(x), "x")), content="1 / cos(x) ^ 2")
  inspect(simplify(differentiate(exp(x), "x")), content="exp(x)")
  inspect(simplify(differentiate(log(x), "x")), content="1 / x")
  inspect(
    simplify(differentiate(asin(x), "x")),
    content="1 / (1 - x ^ 2) ^ 0.5",
  )
  inspect(
    simplify(differentiate(acos(x), "x")),
    content="-1 / (1 - x ^ 2) ^ 0.5",
  )
  inspect(simplify(differentiate(atan(x), "x")), content="1 / (1 + x ^ 2)")
  inspect(simplify(differentiate(sinh(x), "x")), content="cosh(x)")
  inspect(simplify(differentiate(cosh(x), "x")), content="sinh(x)")
  inspect(simplify(differentiate(tanh(x), "x")), content="1 / cosh(x) ^ 2")
  inspect(
    simplify(differentiate(asinh(x), "x")),
    content="1 / (x ^ 2 + 1) ^ 0.5",
  )
  inspect(
    simplify(differentiate(acosh(x), "x")),
    content="1 / ((x - 1) ^ 0.5 * (x + 1) ^ 0.5)",
  )
  inspect(simplify(differentiate(atanh(x), "x")), content="1 / (1 - x ^ 2)")
  inspect(simplify(differentiate(neg(x), "x")), content="-1")
}

///|
test "differentiate binary operations" {
  let sum = simplify(differentiate(sym("x") + sym("y"), "x"))
  inspect(sum, content="1")
  let difference = simplify(differentiate(sym("x") - sym("y"), "x"))
  inspect(difference, content="1")
  let product = simplify(differentiate(sym("x") * sym("x") * sym("y"), "x"))
  inspect(product, content="2 * x * y")
  let quotient = simplify(differentiate(div(sin(sym("x")), sym("x")), "x"))
  inspect(quotient, content="(x * cos(x) - sin(x)) / x ^ 2")
  let reciprocal = simplify(differentiate(div(int(1), sym("x")), "x"))
  let reciprocal_expected = simplify(div(int(-1), pow(sym("x"), int(2))))
  assert_eq(reciprocal, reciprocal_expected)
}

///|
test "differentiate absolute value" {
  let x = sym("x")
  inspect(simplify(differentiate(abs(x), "x")), content="x / abs(x)")
}

///|
test "differentiate power with integer exponent" {
  let result = simplify(differentiate(pow(sym("x"), int(5)), "x"))
  let expected = simplify(
    pow(sym("x"), int(5)) * (int(5) * div(int(1), sym("x"))),
  )
  assert_eq(result, expected)
}

///|
test "differentiate power with variable exponent" {
  let result = simplify(differentiate(pow(sym("x"), sym("x")), "x"))
  let expected = simplify(
    pow(sym("x"), sym("x")) * (log(sym("x")) + sym("x") * div(int(1), sym("x"))),
  )
  assert_eq(result, expected)
}

///|
test "differentiate higher order derivatives" {
  let x = sym("x")
  inspect(simplify(differentiate(sin(x), "x", order=2)), content="-(sin(x))")
  assert_eq(differentiate(sym("x"), "x", order=0), sym("x"))
}
