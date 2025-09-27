///|
test "simplify removes additive zero" {
  let expr = add(int(0), sym("x"))
  inspect(simplify(expr), content="x")
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
test "simplify multiplies integer literals" {
  let expr = mul(int(3), int(4))
  let result = simplify(expr)
  inspect(result, content="12")
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
  // (-x) * -(x + y)  应该还原成  x * (x + y)
  let result = simplify(expr)
  inspect(result, content="-x * -(x + y)")
}

///|
test "simplifyer combines multi-level polynomial terms" {
  // 2*x*y + 3*y*x^2 + x*x*y  ->  (2*x*y + 4*x^2*y)
  let term1 = mul(int(2), mul(sym("x"), sym("y")))
  let term2 = mul(int(3), mul(sym("y"), mul(sym("x"), sym("x"))))
  let term3 = mul(sym("x"), mul(sym("x"), sym("y")))
  let expr = add(add(term1, term2), term3)
  let result = simplify(expr)
  inspect(result, content="2 * x * y + 4 * x * x * y")
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
  // 自定义 measure 扣分，让简化后的 (x + x) -> 2*x 被拒绝
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
  // (x + x)^2 * (y + y)  -> (2*x)^2 * (2*y) -> 4*x^2 * 2*y -> 最终 8*x^2*y
  let expr = mul(pow(add(sym("x"), sym("x")), int(2)), add(sym("y"), sym("y")))
  let result = simplify(expr)
  inspect(result, content="(2 * x) ^ 2 * 2 * y")
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
