///|
test "logic_and handles nested expressions and contradictions" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let nested = logic_normalize(
    LogicExpr::And([
      a.copy(),
      logic_true(),
      logic_normalize(
        LogicExpr::And([logic_normalize(LogicExpr::Not(a.copy())), b.copy()]),
      ),
    ]),
  )
  assert_eq(nested, logic_false())
}

///|
test "logic_and canonicalizes operand order" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let c = logic_symbol("C")
  let normalized = logic_normalize(
    LogicExpr::And([c.copy(), a.copy(), b.copy()]),
  )
  match normalized {
    And(terms) => {
      assert_eq(terms.length(), 3)
      assert_eq(terms[0], a)
      assert_eq(terms[1], b)
      assert_eq(terms[2], c)
    }
    _ => abort("expected conjunction")
  }
}

///|
test "logic_xor collapses parity" {
  let a = logic_symbol("A")
  let expr = logic_normalize(LogicExpr::Xor([a.copy(), a.copy(), logic_true()]))
  assert_eq(expr, logic_true())
}

///|
test "logic_implies and logic_equivalent normalize correctly" {
  let a = logic_symbol("A")
  let implies_self = logic_normalize(LogicExpr::Implies(a.copy(), a.copy()))
  assert_eq(implies_self, logic_true())
  let equivalent_self = logic_normalize(
    LogicExpr::Equivalent(a.copy(), a.copy()),
  )
  assert_eq(equivalent_self, logic_true())
}
