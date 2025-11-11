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
  inspect(reciprocal, content="-1 / x ^ 2")
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
  inspect(result, content="5 * x ^ 4")
}

///|
test "differentiate power with variable exponent" {
  let result = simplify(differentiate(pow(sym("x"), sym("x")), "x"))
  let expected = simplify(
    pow(sym("x"), sym("x")) * (log(sym("x")) + sym("x") * div(int(1), sym("x"))),
  )
  assert_eq(result, expected)
  inspect(result, content="x ^ x * (log(x) + 1)")
}

///|
test "differentiate higher order derivatives" {
  let x = sym("x")
  inspect(simplify(differentiate(sin(x), "x", order=2)), content="-(sin(x))")
  assert_eq(differentiate(sym("x"), "x", order=0), sym("x"))
}

///|
test "differentiate exponential-log chain" {
  let x = sym("x")
  let log_arg = pow(x, int(2)) + int(1)
  let expr = exp(sin(x) * log(log_arg))
  let result = simplify(differentiate(expr, "x"))
  let inner_diff = simplify(
    sin(x) * div(int(2) * x, log_arg) + cos(x) * log(log_arg),
  )
  let expected = simplify(exp(sin(x) * log(log_arg)) * inner_diff)
  assert_eq(result, expected)
  inspect(
    result,
    content="exp(sin(x) * log(x ^ 2 + 1)) * ((2 * x * sin(x)) / (x ^ 2 + 1) + cos(x) * log(x ^ 2 + 1))",
  )
}

///|
test "differentiate quotient of products" {
  let x = sym("x")
  let quadratic = pow(x, int(2))
  let numerator = sin(x) * exp(quadratic)
  let denominator = log(x) + pow(x, int(3))
  let expr = div(numerator, denominator)
  let result = simplify(differentiate(expr, "x"))
  let numerator_diff = simplify(
    sin(x) * exp(quadratic) * (int(2) * x) + cos(x) * exp(quadratic),
  )
  let denominator_diff = simplify(div(int(1), x) + int(3) * pow(x, int(2)))
  let expected = simplify(
    div(
      numerator_diff * denominator - numerator * denominator_diff,
      pow(denominator, int(2)),
    ),
  )
  assert_eq(result, expected)
  inspect(
    result,
    content="((2 * x * sin(x) * exp(x ^ 2) + cos(x) * exp(x ^ 2)) * (log(x) + x ^ 3) - sin(x) * exp(x ^ 2) * (1 / x + 3 * x ^ 2)) / (log(x) + x ^ 3) ^ 2",
  )
}

///|
test "differentiate absolute composite expression" {
  let x = sym("x")
  let cubic = pow(x, int(3))
  let inner = sin(x) * cubic
  let expr = abs(inner)
  let result = simplify(differentiate(expr, "x"))
  let normalized = simplify(div(inner, expr))
  let inner_diff = simplify(int(3) * sin(x) * pow(x, int(2)) + cos(x) * cubic)
  let expected = simplify(normalized * inner_diff)
  assert_eq(result, expected)
  inspect(
    result,
    content="(x ^ 3 * sin(x) * (3 * x ^ 2 * sin(x) + x ^ 3 * cos(x))) / abs(x ^ 3 * sin(x))",
  )
}

///|
test "differentiate nested sine exponential cosine" {
  let x = sym("x")
  let expr = sin(exp(cos(x)))
  let result = simplify(differentiate(expr, "x"))
  let expected = simplify(cos(exp(cos(x))) * exp(cos(x)) * neg(sin(x)))
  assert_eq(result, expected)
  inspect(result, content="-(cos(exp(cos(x))) * exp(cos(x)) * sin(x))")
}

///|
test "differentiate exponential product chain" {
  let x = sym("x")
  let inner = sin(x) * cos(exp(x))
  let expr = exp(inner)
  let result = simplify(differentiate(expr, "x"))
  let inner_diff = simplify(
    neg(exp(x) * sin(x) * sin(exp(x))) + cos(x) * cos(exp(x)),
  )
  let expected = simplify(expr * inner_diff)
  assert_eq(result, expected)
  inspect(
    result,
    content="exp(sin(x) * cos(exp(x))) * (-(exp(x) * sin(x) * sin(exp(x))) + cos(x) * cos(exp(x)))",
  )
}

///|
test "differentiate tangent exponential sine" {
  let x = sym("x")
  let inner = exp(sin(x))
  let expr = tan(inner)
  let result = simplify(differentiate(expr, "x"))
  let inner_diff = simplify(inner * cos(x))
  let expected = simplify(pow(cos(inner), int(-2)) * inner_diff)
  assert_eq(result, expected)
  inspect(result, content="cos(exp(sin(x))) ^ -2 * exp(sin(x)) * cos(x)")
}

///|
