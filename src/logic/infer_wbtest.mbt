///|
test "logic_infer validates modus ponens" {
  let rain = logic_symbol("Rain")
  let wet = logic_symbol("Wet")
  let premises = [
    logic_normalize(LogicExpr::Implies(rain.copy(), wet.copy())),
    rain,
  ]
  assert_eq(logic_infer(premises, wet), true)
}

///|
test "logic_infer detects unsupported conclusion" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let premises = [a.copy()]
  let conclusion = logic_normalize(LogicExpr::And([a, b]))
  assert_eq(logic_infer(premises, conclusion), false)
}

///|
test "logic_infer treats inconsistent premises as vacuously true" {
  let a = logic_symbol("A")
  let premises = [a.copy(), logic_normalize(LogicExpr::Not(a.copy()))]
  let conclusion = logic_symbol("B")
  assert_eq(logic_infer(premises, conclusion), true)
}

///|
test "logic_infer supports chained implications" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let c = logic_symbol("C")
  let premises = [
    logic_normalize(LogicExpr::Implies(a.copy(), b.copy())),
    logic_normalize(LogicExpr::Implies(b.copy(), c.copy())),
    a,
  ]
  assert_eq(logic_infer(premises, c), true)
}

///|
test "logic_infer resolves disjunction elimination" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let premises = [
    logic_normalize(
      LogicExpr::And([
        logic_normalize(LogicExpr::Or([a.copy(), b.copy()])),
        logic_normalize(LogicExpr::Not(a.copy())),
      ]),
    ),
  ]
  assert_eq(logic_infer(premises, b), true)
}

///|
test "logic_infer collapses xor with known branch" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let premises = [
    logic_normalize(LogicExpr::Xor([a.copy(), b.copy()])),
    a.copy(),
  ]
  let conclusion = logic_normalize(LogicExpr::Not(b))
  assert_eq(logic_infer(premises, conclusion), true)
}

///|
test "logic_infer rejects ambiguous xor conclusions" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let premises = [logic_normalize(LogicExpr::Xor([a.copy(), b.copy()]))]
  assert_eq(logic_infer(premises, a), false)
}
