///|
test "simplify removes additive zero" {
  let expr = add(int(0), sym("x"))
  inspect(simplify(expr), content="x")
}

///|
test "rationalize expr maps well-known constants" {
  let pi_expr = rationalize_expr(double(3.141592653589793))
  inspect(pi_expr, content="pi")
  let golden_expr = rationalize_expr(double(1.618033988749895))
  inspect(golden_expr, content="GoldenRatio")
}

///|
test "rationalize expr finds constant multiples" {
  let value = double(1.5707963267948966) // pi / 2
  inspect(rationalize_expr(value), content="1 / 2 * pi")
}

///|
test "rationalize expr finds constant offsets" {
  let value = double(3.641592653589793) // pi + 1 / 2
  inspect(rationalize_expr(value), content="pi + 1 / 2")
}

///|
test {
  let value = double(3.618033988749895) // GoldenRatio + 2
  inspect(rationalize_expr(value), content="GoldenRatio + 2")
}

///|
test "rationalize expr finds two constant combination" {
  let value = double(0.5 * 3.141592653589793 + 0.25 * 0.6931471805599453)
  inspect(
    rationalize_expr(value, tolerance=1.0e-6),
    content="1 / 2 * pi + 1 / 4 * Log2",
  )
}

///|
test "rationalize expr finds triple constant combination with full search" {
  let value = double(1.9364883435687271)
  inspect(
    rationalize_expr(value, tolerance=1.0e-6, full=true),
    content="1 / 2 * pi + 1 / 3 * EulerGamma + 1 / 4 * Log2",
  )
}

///|
test "simplify cancels reciprocal powers inside products" {
  let x = sym("x")
  let expr = pow(x, int(3)) * div(int(1), x)
  inspect(simplify(expr), content="x ^ 2")
}

///|
test "simplify collapses odd root power" {
  let x = sym("x")
  let expr = pow(pow(x, int(3)), div(int(1), int(3)))
  inspect(simplify(expr), content="x")
}

///|
test "simplify collapses even root power to absolute" {
  let x = sym("x")
  let expr = pow(pow(x, int(2)), div(int(1), int(2)))
  inspect(simplify(expr), content="abs(x)")
}

///|
test "simplify log of exponential" {
  let x = sym("x")
  inspect(simplify(log(exp(x))), content="x")
}

///|
test "simplify exponential of logarithm" {
  let x = sym("x")
  inspect(simplify(exp(log(x))), content="x")
}

///|
test "simplify log addition to multiplication" {
  let a = sym("a")
  let b = sym("b")
  let expr = log(a) + log(b)
  inspect(simplify(expr), content="log(a * b)")
}

///|
test "simplify log subtraction to division" {
  let a = sym("a")
  let b = sym("b")
  let expr = log(a) - log(b)
  inspect(simplify(expr), content="log(a / b)")
}

///|
test "simplify sin square plus cos square" {
  let x = sym("x")
  let expr = add(pow(sin(x), int(2)), pow(cos(x), int(2)))
  inspect(simplify(expr), content="1")
}

///|
test "simplify cos square plus sin square" {
  let x = sym("x")
  let expr = add(pow(cos(x), int(2)), pow(sin(x), int(2)))
  inspect(simplify(expr), content="1")
}

///|
test "simplify one plus tan square" {
  let x = sym("x")
  let expr = add(int(1), pow(tan(x), int(2)))
  inspect(simplify(expr), content="1 / cos(x) ^ 2")
}

///|
test "simplify tan square plus one" {
  let x = sym("x")
  let expr = add(pow(tan(x), int(2)), int(1))
  inspect(simplify(expr), content="1 / cos(x) ^ 2")
}

///|
test "simplify one plus tan inverse square" {
  let x = sym("x")
  let expr = add(int(1), pow(tan(x), int(-2)))
  inspect(simplify(expr), content="1 / sin(x) ^ 2")
}

///|
test "simplify tan inverse square plus one" {
  let x = sym("x")
  let expr = add(pow(tan(x), int(-2)), int(1))
  inspect(simplify(expr), content="1 / sin(x) ^ 2")
}

///|
test "simplify sine addition formula" {
  let x = sym("x")
  let y = sym("y")
  let expr = add(mul(sin(x), cos(y)), mul(cos(x), sin(y)))
  inspect(simplify(expr), content="sin(x + y)")
}

///|
test "simplify sine subtraction formula" {
  let x = sym("x")
  let y = sym("y")
  let expr = sub(mul(sin(x), cos(y)), mul(cos(x), sin(y)))
  inspect(simplify(expr), content="sin(x - y)")
}

///|
test "simplify sine subtraction swapped order" {
  let x = sym("x")
  let y = sym("y")
  let expr = sub(mul(cos(x), sin(y)), mul(sin(x), cos(y)))
  inspect(simplify(expr), content="sin(y - x)")
}

///|
test "simplify cosine addition formula" {
  let x = sym("x")
  let y = sym("y")
  let expr = sub(mul(cos(x), cos(y)), mul(sin(x), sin(y)))
  inspect(simplify(expr), content="cos(x + y)")
}

///|
test "simplify cosine subtraction formula" {
  let x = sym("x")
  let y = sym("y")
  let expr = add(mul(cos(x), cos(y)), mul(sin(x), sin(y)))
  inspect(simplify(expr), content="cos(x - y)")
}

///|
test "simplify double angle from product" {
  let x = sym("x")
  let expr = mul(int(2), mul(sin(x), cos(x)))
  inspect(simplify(expr), content="sin(2 * x)")
}

///|
test "simplify cosine double angle difference" {
  let x = sym("x")
  let expr = sub(pow(cos(x), int(2)), pow(sin(x), int(2)))
  inspect(simplify(expr), content="cos(2 * x)")
}

///|
test {
  let x = sym("x")
  let expr = int(1) - int(2) * pow(sin(x), int(2))
  inspect(simplify(expr), content="cos(2 * x)")
}

///|
test "simplify cosine double angle negative difference" {
  let x = sym("x")
  let expr = sub(pow(sin(x), int(2)), pow(cos(x), int(2)))
  inspect(simplify(expr), content="-(cos(2 * x))")
}

///|
test "simplify one minus double sine square" {
  let x = sym("x")
  let expr = sub(int(1), mul(int(2), pow(sin(x), int(2))))
  inspect(simplify(expr), content="cos(2 * x)")
}

///|
test {
  let x = sym("x")
  let expr = int(1) - int(2) * pow(cos(x), int(2))
  inspect(simplify(expr), content="-(cos(2 * x))")
}

///|
test "simplify double cosine square minus one" {
  let x = sym("x")
  let expr = sub(mul(int(2), pow(cos(x), int(2))), int(1))
  inspect(simplify(expr), content="cos(2 * x)")
}

///|
test "simplify double sine square minus one" {
  let x = sym("x")
  let expr = sub(mul(int(2), pow(sin(x), int(2))), int(1))
  inspect(simplify(expr), content="-(cos(2 * x))")
}

///|
test "simplify one minus double cosine square" {
  let x = sym("x")
  let expr = sub(int(1), mul(int(2), pow(cos(x), int(2))))
  inspect(simplify(expr), content="-(cos(2 * x))")
}

///|
test "simplify tangent addition formula" {
  let x = sym("x")
  let y = sym("y")
  let numerator = add(tan(x), tan(y))
  let denominator = sub(int(1), mul(tan(x), tan(y)))
  let expr = div(numerator, denominator)
  inspect(simplify(expr), content="tan(x + y)")
}

///|
test "simplify tangent subtraction formula" {
  let x = sym("x")
  let y = sym("y")
  let numerator = sub(tan(x), tan(y))
  let denominator = add(int(1), mul(tan(x), tan(y)))
  let expr = div(numerator, denominator)
  inspect(simplify(expr), content="tan(x - y)")
}

///|
test "simplify tangent double angle" {
  let x = sym("x")
  let numerator = mul(int(2), tan(x))
  let denominator = sub(int(1), pow(tan(x), int(2)))
  let expr = div(numerator, denominator)
  inspect(simplify(expr), content="tan(2 * x)")
}

///|
test "simplify sine sum to product" {
  let x = sym("x")
  let y = sym("y")
  inspect(simplify(add(sin(x), sin(y))), content="sin(x) + sin(y)")
}

///|
test "simplify sine difference to product" {
  let x = sym("x")
  let y = sym("y")
  inspect(simplify(sub(sin(x), sin(y))), content="sin(x) - sin(y)")
}

///|
test "simplify sine difference swapped to product" {
  let x = sym("x")
  let y = sym("y")
  inspect(simplify(sub(sin(y), sin(x))), content="sin(y) - sin(x)")
}

///|
test "simplify cosine sum to product" {
  let x = sym("x")
  let y = sym("y")
  inspect(simplify(add(cos(x), cos(y))), content="cos(x) + cos(y)")
}

///|
test "simplify cosine difference to product" {
  let x = sym("x")
  let y = sym("y")
  inspect(simplify(sub(cos(x), cos(y))), content="cos(x) - cos(y)")
}

///|
test "simplify cosine difference swapped to product" {
  let x = sym("x")
  let y = sym("y")
  inspect(simplify(sub(cos(y), cos(x))), content="cos(y) - cos(x)")
}

///|
test "simplify sine sum special" {
  let x = sym("x")
  let y = sym("y")
  let expr = add(sin(add(x, y)), sin(sub(x, y)))
  inspect(expr, content="sin(x + y) + sin(x - y)")
  inspect(simplify(expr), content="2 * sin(x) * cos(y)")
}

///|
test "simplify sine difference special" {
  let x = sym("x")
  let y = sym("y")
  let expr = sub(sin(add(x, y)), sin(sub(x, y)))
  inspect(expr, content="sin(x + y) - sin(x - y)")
  inspect(simplify(expr), content="2 * cos(x) * sin(y)")
}

///|
test "simplify cosine sum special" {
  let x = sym("x")
  let y = sym("y")
  let expr = add(cos(add(x, y)), cos(sub(x, y)))
  inspect(expr, content="cos(x + y) + cos(x - y)")
  inspect(simplify(expr), content="2 * cos(x) * cos(y)")
}

///|
test "simplify cosine difference special" {
  let x = sym("x")
  let y = sym("y")
  let expr = sub(cos(add(x, y)), cos(sub(x, y)))
  inspect(expr, content="cos(x + y) - cos(x - y)")
  inspect(simplify(expr), content="-(2 * sin(x) * sin(y))")
}

///|
test "simplify cosine difference special swapped" {
  let x = sym("x")
  let y = sym("y")
  let expr = sub(cos(sub(x, y)), cos(add(x, y)))
  inspect(expr, content="cos(x - y) - cos(x + y)")
  inspect(simplify(expr), content="2 * sin(x) * sin(y)")
}

///|
test "simplify cosh squared minus sinh squared" {
  let x = sym("x")
  inspect(simplify(pow(cosh(x), int(2)) - pow(sinh(x), int(2))), content="1")
}

///|
test "simplify one minus tanh square" {
  let x = sym("x")
  inspect(simplify(int(1) - pow(tanh(x), int(2))), content="1 / cosh(x) ^ 2")
}

///|
test "simplify tanh inverse square minus one" {
  let x = sym("x")
  inspect(simplify(pow(tanh(x), int(-2)) - int(1)), content="1 / sinh(x) ^ 2")
}

///|
test "simplify hyperbolic sinh addition formula" {
  let x = sym("x")
  let y = sym("y")
  inspect(
    simplify(sinh(x) * cosh(y) + cosh(x) * sinh(y)),
    content="sinh(x + y)",
  )
}

///|
test "simplify hyperbolic sinh subtraction formula" {
  let x = sym("x")
  let y = sym("y")
  inspect(
    simplify(sinh(x) * cosh(y) - cosh(x) * sinh(y)),
    content="sinh(x - y)",
  )
}

///|
test "simplify hyperbolic cosh addition formula" {
  let x = sym("x")
  let y = sym("y")
  inspect(
    simplify(cosh(x) * cosh(y) + sinh(x) * sinh(y)),
    content="cosh(x + y)",
  )
}

///|
test "simplify hyperbolic cosh subtraction formula" {
  let x = sym("x")
  let y = sym("y")
  inspect(
    simplify(cosh(x) * cosh(y) - sinh(x) * sinh(y)),
    content="cosh(x - y)",
  )
}

///|
test "simplify hyperbolic sinh double angle" {
  let x = sym("x")
  inspect(simplify(mul(int(2), mul(sinh(x), cosh(x)))), content="sinh(2 * x)")
}

///|
test "simplify hyperbolic cosh double angle" {
  let x = sym("x")
  inspect(
    simplify(pow(cosh(x), int(2)) + pow(sinh(x), int(2))),
    content="cosh(2 * x)",
  )
}

///|
test "simplify sinh sum special" {
  let x = sym("x")
  let y = sym("y")
  inspect(simplify(sinh(x + y) + sinh(x - y)), content="2 * sinh(x) * cosh(y)")
}

///|
test "simplify sinh difference special" {
  let x = sym("x")
  let y = sym("y")
  inspect(simplify(sinh(x + y) - sinh(x - y)), content="2 * cosh(x) * sinh(y)")
}

///|
test "simplify cosh sum special" {
  let x = sym("x")
  let y = sym("y")
  inspect(simplify(cosh(x + y) + cosh(x - y)), content="2 * cosh(x) * cosh(y)")
}

///|
test "simplify cosh difference special" {
  let x = sym("x")
  let y = sym("y")
  inspect(simplify(cosh(x + y) - cosh(x - y)), content="2 * sinh(x) * sinh(y)")
}

///|
test "simplify cosh plus sinh to exp" {
  let x = sym("x")
  inspect(simplify(cosh(x) + sinh(x)), content="exp(x)")
  inspect(simplify(sinh(x) + cosh(x)), content="exp(x)")
}

///|
test "simplify cosh minus sinh to exp" {
  let x = sym("x")
  inspect(simplify(cosh(x) - sinh(x)), content="exp(-x)")
  inspect(simplify(sinh(x) - cosh(x)), content="-(exp(-x))")
}

///|
test "rationalize expr keeps recurring decimals with base10" {
  let value = double(1.0 / 8192.0)
  let result = rationalize_expr(value)
  inspect(result, content="0.0001220703125")
}

///|
test "rationalize expr exact mode returns binary fraction" {
  let value = double(1.0 / 8192.0)
  let result = rationalize_expr(value, rational_conversion="exact")
  inspect(result, content="1 / 8192")
}

///|
test "rationalize expr full search finds simple fraction" {
  let value = double(0.333333333)
  let default_expr = rationalize_expr(value, tolerance=1.0e-6)
  inspect(default_expr, content="333333333 / 1000000000")
  let full_expr = rationalize_expr(value, tolerance=1.0e-6, full=true)
  inspect(full_expr, content="1 / 3")
  match full_expr {
    Expr::Binary(BinaryOp::Div, Expr::Int(numerator), Expr::Int(denominator)) => {
      assert_eq(numerator, 1)
      assert_eq(denominator, 3)
    }
    other => abort("expected 1/3, got " + other.to_string())
  }
}

///|
test "simplify mirrors simplify by default" {
  let expr = add(int(0), sym("y"))
  let result = simplify(expr)
  inspect(result, content="y")
}

///|
test "simplify keeps double neg without inverse flag" {
  let expr = neg(neg(sym("z")))
  let result = simplify(expr)
  inspect(result, content="-(-z)")
}

///|
test "simplify cancels double neg with inverse flag" {
  let expr = neg(neg(sym("z")))
  let result = simplify(expr, inverse=true)
  inspect(result, content="z")
}

///|
test "simplify respects custom measure" {
  let expr = add(int(2), int(3))
  let measure = (candidate : Expr) => match candidate {
    Expr::Int(_) => 100.0
    _ => count_ops(candidate)
  }
  let result = simplify(expr, measure~)
  inspect(result, content="2 + 3")
}

///|
test "simplify combines duplicate addends" {
  let expr = add(sym("x"), sym("x"))
  let result = simplify(expr)
  inspect(result, content="2 * x")
}

///|
test "simplify combines linear coefficients" {
  let expr = add(
    mul(int(2), mul(sym("x"), sym("y"))),
    mul(int(3), mul(sym("x"), sym("y"))),
  )
  let result = simplify(expr)
  inspect(result, content="5 * x * y")
}

///|
test "simplify aggregates repeated symbol in larger sum" {
  let expr = add(add(sym("x"), sym("y")), sym("x"))
  let result = simplify(expr)
  inspect(result, content="2 * x + y")
}

///|
test "simplify merges multivariate terms" {
  let term1 = mul(sym("x"), sym("y"))
  let term2 = mul(int(2), mul(sym("x"), sym("y")))
  let term3 = mul(int(3), mul(sym("y"), sym("x")))
  let expr = add(add(term1, term2), term3)
  let result = simplify(expr)
  inspect(result, content="6 * x * y")
}

///|
test "simplify factors common additive blocks" {
  let base = add(sym("x"), sym("y"))
  let expr = add(mul(int(2), base), mul(int(3), base))
  let result = simplify(expr)
  inspect(result, content="5 * (x + y)")
}

///|
test "simplify cancels additive inverse" {
  let expr = add(sym("x"), neg(sym("x")))
  let result = simplify(expr)
  inspect(result, content="0")
}

///|
test "simplify combines mixed numeric coefficients" {
  let expr = add(mul(double(1.5), sym("x")), mul(int(2), sym("x")))
  let result = simplify(expr)
  inspect(result, content="3.5 * x")
}

///|
test "simplifyer handles nested negation in product" {
  let expr = mul(neg(sym("x")), neg(add(sym("x"), sym("y"))))
  // (-x) * -(x + y) should simplify to x * (x + y)
  let result = simplify(expr)
  inspect(result, content="x * (x + y)")
}

///|
test "simplifyer combines multi-level polynomial terms" {
  // 2*x*y + 3*y*x^2 + x*x*y  ->  (2*x*y + 4*x^2*y)
  let term1 = mul(int(2), mul(sym("x"), sym("y")))
  let term2 = mul(int(3), mul(sym("y"), mul(sym("x"), sym("x"))))
  let term3 = mul(sym("x"), mul(sym("x"), sym("y")))
  let expr = add(add(term1, term2), term3)
  let result = simplify(expr)
  inspect(result, content="2 * x * y + 4 * y * x ^ 2")
}

///|
test "simplifyer normalizes factors across addition" {
  // x*(y*z) + z*(x*y) + y*(z*x)  -> 3 * x*y*z
  let expr = add(
    mul(sym("x"), mul(sym("y"), sym("z"))),
    add(
      mul(sym("z"), mul(sym("x"), sym("y"))),
      mul(sym("y"), mul(sym("z"), sym("x"))),
    ),
  )
  let result = simplify(expr)
  inspect(result, content="3 * x * y * z")
}

///|
test "simplifyer respects measure when candidate larger" {
  // Custom measure penalizes further simplification of (x + x)
  let expr = add(sym("x"), sym("x"))
  let measure = (candidate : Expr) => match candidate {
    Expr::Binary(BinaryOp::Mul, _, _) => 99.0
    _ => count_ops(candidate)
  }
  let result = simplify(expr, measure~)
  inspect(result, content="x + x")
}

///|
test "simplifyer cascades through pow and mul" {
  // (x + x)^2 * (y + y) -> (2*x)^2 * (2*y) -> 4*x^2 * 2*y -> final 8*x^2*y
  let expr = mul(pow(add(sym("x"), sym("x")), int(2)), add(sym("y"), sym("y")))
  let result = simplify(expr)
  inspect(result, content="8 * x ^ 2 * y")
}

///|
test "product rule differentiation" {
  let expr = mul(sym("x"), sym("x"))
  let derivative = differentiate(expr, "x")
  let simplified = simplify(derivative)
  inspect(simplified, content="2 * x")
}

///|
test "evaluation with lookup" {
  let expr = add(mul(sym("x"), sym("x")), double(2.0))
  let result = evaluate(expr, (name : String) => if name == "x" {
    Some(3.0)
  } else {
    None
  })
  inspect(result, content="Ok(11)")
}

///|
test "inverse cancellation handles trig pair" {
  let expr = atan(tan(cos(acos(cos(sin(asin(exp(log(sym("x"))))))))))
  let result = simplify(expr, inverse=true)
  inspect(result, content="cos(x)")
}

///|
test "simplify multiplies integer literals" {
  let expr = mul(int(3), int(4))
  let result = simplify(expr)
  assert_eq(result, int(12))
}

///|
test "simplify combines multiplicative coefficients" {
  let expr = mul(int(2), mul(int(3), sym("x")))
  inspect(simplify(expr), content="6 * x")
}

///|
test "simplify merges repeated symbols into powers" {
  let expr = mul(sym("x"), sym("x"))
  inspect(simplify(expr), content="x ^ 2")
}

///|
test "simplify combines existing powers" {
  let expr = mul(pow(sym("x"), int(3)), sym("x"))
  inspect(simplify(expr), content="x ^ 4")
}

///|
test "simplify mixes integer and double coefficients" {
  let x = sym("x")
  let expr = x * double(2.5) * int(4) * x * double(1.5) + x * int(2) * x
  inspect(simplify(expr), content="17 * x ^ 2")
}

///|
test "simplify pow collapses nested exponent" {
  let expr = pow(pow(sym("x"), int(2)), int(3))
  inspect(simplify(expr), content="x ^ 6")
}

///|
test "simplify pow distributes coefficient with float exponent" {
  let expr = pow(mul(double(2.0), sym("x")), double(2.5))
  inspect(simplify(expr), content="5.65685424949238 * x ^ 2.5")
}

///|
test "simplify pow handles negative float exponent" {
  let expr = pow(mul(double(3.0), sym("x")), double(-1.5))
  inspect(simplify(expr), content="1 / (5.196152422706632 * x ^ 1.5)")
}

///|
test "simplify pow distributes coefficient" {
  let expr = pow(mul(int(3), sym("x")), int(2))
  inspect(simplify(expr), content="9 * x ^ 2")
}

///|
test "simplify pow with integer base" {
  inspect(simplify(pow(int(2), int(3))), content="8")
  inspect(simplify(pow(int(-1), int(4))), content="1")
}

///|
test "simplify pow with double base" {
  inspect(simplify(pow(double(2.0), int(3))), content="8")
}

///|
test "simplify pow handles negative integer exponent" {
  inspect(simplify(pow(int(2), int(-3))), content="1 / 8")
  inspect(simplify(pow(int(-1), int(-3))), content="-1")
}

///|
test "simplify pow handles negative double exponent" {
  inspect(simplify(pow(double(2.0), int(-2))), content="0.25")
}

///|
test {
  let x = sym("x")
  let expr = pow(pow(x + int(5) + x * int(2), double(-1.5)), int(2))
  inspect(simplify(expr), content="(3 * x + 5) ^ -3")
}

///|
test {
  let x = sym("x")
  let expr = pow(double(2.0) * x, double(2.5))
  inspect(simplify(expr), content="5.65685424949238 * x ^ 2.5")
}
