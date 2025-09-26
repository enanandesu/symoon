///|
test "simplify removes additive zero" {
  let expr = add(int(0), sym("x"))
  assert_eq(simplify(expr), sym("x"))
}

///|
test "simplify mirrors simplify by default" {
  let expr = add(int(0), sym("y"))
  let result = simplify(expr)
  assert_eq(result, sym("y"))
}

///|
test "simplify keeps double neg without inverse flag" {
  let expr = neg(neg(sym("z")))
  let result = simplify(expr)
  assert_eq(result, neg(neg(sym("z"))))
}

///|
test "simplify cancels double neg with inverse flag" {
  let expr = neg(neg(sym("z")))
  let result = simplify(expr, rational = true)
  assert_eq(result, sym("z"))
}

///|
test "simplify multiplies integer literals" {
  let expr = mul(int(3), int(4))
  let result = simplify(expr)
  assert_eq(result, int(12))
}

///|
test "simplify respects custom measure" {
  let expr = add(int(2), int(3))
  let measure = (candidate : Expr) => match candidate {
    Expr::Int(_) => 100.0
    _ => count_ops(candidate)
  }
  let result = simplify(expr, measure = measure)
  assert_eq(result, expr)
}

///|
test "simplify combines duplicate addends" {
  let expr = add(sym("x"), sym("x"))
  let result = simplify(expr)
  assert_eq(result, mul(int(2), sym("x")))
}

///|
test "simplify combines linear coefficients" {
  let expr = add(mul(int(2), mul(sym("x"), sym("y"))), mul(int(3), mul(sym("x"), sym("y"))))
  let result = simplify(expr)
  assert_eq(result, mul(int(5), mul(sym("x"), sym("y"))))
}

///|
test "simplify aggregates repeated symbol in larger sum" {
  let expr = add(add(sym("x"), sym("y")), sym("x"))
  let result = simplify(expr)
  let expected = add(mul(int(2), sym("x")), sym("y"))
  assert_eq(result, expected)
}

///|
test "simplify merges multivariate terms" {
  let term1 = mul(sym("x"), sym("y"))
  let term2 = mul(int(2), mul(sym("x"), sym("y")))
  let term3 = mul(int(3), mul(sym("y"), sym("x")))
  let expr = add(add(term1, term2), term3)
  let result = simplify(expr)
  let expected = mul(int(6), mul(sym("x"), sym("y")))
  assert_eq(result, expected)
}

///|
test "simplify factors common additive blocks" {
  let base = add(sym("x"), sym("y"))
  let expr = add(mul(int(2), base), mul(int(3), base))
  let result = simplify(expr)
  let expected = mul(int(5), base)
  assert_eq(result, expected)
}

///|
test "simplify cancels additive inverse" {
  let expr = add(sym("x"), neg(sym("x")))
  let result = simplify(expr)
  assert_eq(result, int(0))
}

///|
test "simplify combines mixed numeric coefficients" {
  let expr = add(mul(double(1.5), sym("x")), mul(int(2), sym("x")))
  let result = simplify(expr)
  let expected = mul(double(3.5), sym("x"))
  assert_eq(result, expected)
}

///|
test "simplifyer handles nested negation in product" {
  let expr = mul(neg(sym("x")), neg(add(sym("x"), sym("y"))))
  // (-x) * -(x + y)  应该还原成  x * (x + y)
  let result = simplify(expr)
  let expected = mul(sym("x"), add(sym("x"), sym("y")))
  assert_eq(result, expected)
}

///|
test "simplifyer combines multi-level polynomial terms" {
  // 2*x*y + 3*y*x^2 + x*x*y  ->  (2*x*y + 4*x^2*y)
  let term1 = mul(int(2), mul(sym("x"), sym("y")))
  let term2 = mul(int(3), mul(sym("y"), mul(sym("x"), sym("x"))))
  let term3 = mul(sym("x"), mul(sym("x"), sym("y")))
  let expr = add(add(term1, term2), term3)
  let result = simplify(expr)
  inspect(
    result,
    content=(
      #|Binary(Add, Binary(Mul, Int(2), Binary(Mul, Symbol({name: "x"}), Symbol({name: "y"}))), Binary(Mul, Int(4), Binary(Mul, Binary(Mul, Symbol({name: "x"}), Symbol({name: "x"})), Symbol({name: "y"}))))
    ),
  )
}

///|
test "simplifyer normalizes factors across addition" {
  // x*(y*z) + z*(x*y) + y*(z*x)  -> 3 * x*y*z
  let expr = add(
    mul(sym("x"), mul(sym("y"), sym("z"))),
    add(
      mul(sym("z"), mul(sym("x"), sym("y"))),
      mul(sym("y"), mul(sym("z"), sym("x")))
    )
  )
  let result = simplify(expr)
  inspect(result, content = (#|Binary(Mul, Int(3), Binary(Mul, Binary(Mul, Symbol({name: "x"}), Symbol({name: "y"})), Symbol({name: "z"})))
  ))
}

///|
test "simplifyer respects measure when candidate larger" {
  // 自定义 measure 扣分，让简化后的 (x + x) -> 2*x 被拒绝
  let expr = add(sym("x"), sym("x"))
  let measure = (candidate : Expr) => match candidate {
    Expr::Binary(BinaryOp::Mul, _, _) => 99.0
    _ => count_ops(candidate)
  }
  let result = simplify(expr, measure = measure)
  assert_eq(result, expr)
}

///|
test "simplifyer cascades through pow and mul" {
  // (x + x)^2 * (y + y)  -> (2*x)^2 * (2*y) -> 4*x^2 * 2*y -> 最终 8*x^2*y
  let expr = mul(pow(add(sym("x"), sym("x")), int(2)), add(sym("y"), sym("y")))
  let result = simplify(expr)
  inspect(
    result,
    content=(
      #|Binary(Mul, Binary(Pow, Binary(Mul, Int(2), Symbol({name: "x"})), Int(2)), Binary(Mul, Int(2), Symbol({name: "y"})))
    ),
  )
}


///|
test "product rule differentiation" {
  let expr = mul(sym("x"), sym("x"))
  let derivative = differentiate(expr, "x")
  let simplified = simplify(derivative)
  let expected = add(sym("x"), sym("x"))
  assert_eq(simplified, expected)
  inspect(
    simplified,
    content=(
      #|Binary(Add, Symbol({name: "x"}), Symbol({name: "x"}))
    ),
  )
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
