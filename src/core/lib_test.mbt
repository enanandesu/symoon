///|
test "simplify removes additive zero" {
  let expr = add(int(0), sym("x"))
  assert_eq(simplify(expr), sym("x"))
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
