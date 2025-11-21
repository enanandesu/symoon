///|
test "logic_apply_assignments normalizes nested structures" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let expr = logic_normalize(
    LogicExpr::And([
      logic_true(),
      logic_normalize(
        LogicExpr::And([
          a.copy(),
          logic_true(),
          logic_normalize(LogicExpr::Not(b.copy())),
        ]),
      ),
    ]),
  )
  let env : Array[(String, Bool)] = [("B", false)]
  let applied = logic_apply_assignments(expr, env)
  assert_eq(applied, a)
}

///|
test "logic_apply_and_eval returns final truth when determined" {
  let rain = logic_symbol("Rain")
  let expr = logic_normalize(LogicExpr::Or([rain.copy(), logic_false()]))
  let env : Array[(String, Bool)] = [("Rain", true)]
  let (reduced, value) = logic_apply_and_eval(expr, env)
  assert_eq(reduced, logic_true())
  assert_eq(value, Some(true))
}

///|
test "logic_apply_and_eval reports None when unknown remains" {
  let rain = logic_symbol("Rain")
  let windy = logic_symbol("Windy")
  let expr = logic_normalize(LogicExpr::And([rain.copy(), windy.copy()]))
  let env : Array[(String, Bool)] = [("Rain", true)]
  let (reduced, value) = logic_apply_and_eval(expr, env)
  assert_eq(reduced, windy)
  assert_eq(value, None)
}
