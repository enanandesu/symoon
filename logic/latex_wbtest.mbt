///|
test "logic_to_latex formats conjunctions and negations" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let expr = logic_normalize(LogicExpr::Not(LogicExpr::And([a.copy(), b.copy()])))
  assert_eq(logic_to_latex(expr), "\\neg \\left(A \\land B\\right)")
}

///|
test "logic_to_latex handles implications and equivalence" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let c = logic_symbol("C")
  let expr = logic_normalize(
    LogicExpr::Implies(
      LogicExpr::Or([a.copy(), b.copy()]),
      LogicExpr::Equivalent(b.copy(), c.copy()),
    ),
  )
  assert_eq(
    logic_to_latex(expr),
    "\\left(A \\lor B\\right) \\rightarrow \\left(B \\leftrightarrow C\\right)",
  )
}

///|
test "logic_to_latex formats xor and constants" {
  let expr = logic_normalize(
    LogicExpr::Xor([logic_true(), logic_symbol("Flag"), logic_false()]),
  )
  assert_eq(logic_to_latex(expr), "\\top \\oplus Flag \\oplus \\bot")
}
