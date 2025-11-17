///|
test "logic_simplify_with_assignments replaces known values" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let expr = logic_normalize(
    LogicExpr::And([a.copy(), logic_normalize(LogicExpr::Not(b.copy()))]),
  )
  let env : Array[(String, Bool)] = [("A", true)]
  let reduced = logic_simplify_with_assignments(expr, env)
  assert_eq(reduced, logic_normalize(LogicExpr::Not(b)))
}

///|
test "logic_simplify_with_assignments collapses disjunctions" {
  let rain = logic_symbol("Rain")
  let windy = logic_symbol("Windy")
  let expr = logic_normalize(LogicExpr::Or([rain.copy(), windy.copy()]))
  let env : Array[(String, Bool)] = [("Windy", false), ("Rain", true)]
  let reduced = logic_simplify_with_assignments(expr, env)
  assert_eq(reduced, logic_true())
}

///|
test "logic_simplify_with_assignments simplifies implications" {
  let premise = logic_symbol("P")
  let conclusion = logic_symbol("Q")
  let expr = logic_normalize(
    LogicExpr::Implies(premise.copy(), conclusion.copy()),
  )
  let env : Array[(String, Bool)] = [("P", true)]
  let reduced = logic_simplify_with_assignments(expr, env)
  assert_eq(reduced, conclusion)
}

///|
