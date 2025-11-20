///|
test "logic_and simplifies nested expressions" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let expr = logic_normalize(
    LogicExpr::And([
      a.copy(),
      logic_true(),
      logic_normalize(LogicExpr::And([b.copy(), logic_true()])),
    ]),
  )
  match expr {
    And(terms) => {
      assert_eq(terms.length(), 2)
      let lhs = terms[0]
      let rhs = terms[1]
      match (lhs, rhs) {
        (Symbol(name_a), Symbol(name_b)) => {
          assert_eq(name_a, "A")
          assert_eq(name_b, "B")
        }
        _ => abort("expected flattened conjunction")
      }
    }
    _ => abort("expected conjunction result")
  }
  let contradiction = logic_normalize(
    LogicExpr::And([a.copy(), logic_normalize(LogicExpr::Not(a.copy()))]),
  )
  assert_eq(contradiction, logic_false())
}

///|
test "logic_and canonicalizes operand order" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let expr1 = logic_normalize(LogicExpr::And([a.copy(), b.copy()]))
  let expr2 = logic_normalize(LogicExpr::And([b, a]))
  assert_eq(expr1, expr2)
}

///|
test "logic_or short circuits and detects tautologies" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let expr = logic_normalize(
    LogicExpr::Or([
      logic_false(),
      a.copy(),
      logic_normalize(LogicExpr::Or([b.copy(), logic_false()])),
    ]),
  )
  match expr {
    Or(terms) => assert_eq(terms.length(), 2)
    _ => abort("expected disjunction")
  }
  let tautology = logic_normalize(
    LogicExpr::Or([a.copy(), logic_normalize(LogicExpr::Not(a.copy()))]),
  )
  assert_eq(tautology, logic_true())
}

///|
test "logic_or canonicalizes operand order" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let expr1 = logic_normalize(LogicExpr::Or([a.copy(), b.copy()]))
  let expr2 = logic_normalize(LogicExpr::Or([b, a]))
  assert_eq(expr1, expr2)
}

///|
test "logic_xor cancels duplicates and tracks parity" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let reduced = logic_normalize(LogicExpr::Xor([a.copy(), a.copy(), b.copy()]))
  assert_eq(reduced, b)
  let toggled = logic_normalize(LogicExpr::Xor([a.copy(), logic_true()]))
  match toggled {
    Not(inner) => assert_eq(inner, a)
    _ => abort("expected negated symbol")
  }
}

///|
test "logic_xor canonicalizes operand order" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let expr1 = logic_normalize(LogicExpr::Xor([a.copy(), b.copy()]))
  let expr2 = logic_normalize(LogicExpr::Xor([b, a]))
  assert_eq(expr1, expr2)
}

///|
test "logic_implies and equivalent follow boolean identities" {
  let a = logic_symbol("A")
  let implication = logic_normalize(LogicExpr::Implies(a.copy(), a.copy()))
  assert_eq(implication, logic_true())
  let negated = logic_normalize(LogicExpr::Implies(a.copy(), logic_false()))
  match negated {
    Not(inner) => assert_eq(inner, a)
    _ => abort("expected negated antecedent")
  }
  let equivalence = logic_normalize(LogicExpr::Equivalent(a.copy(), a.copy()))
  assert_eq(equivalence, logic_true())
}

///|
test "logic_eval resolves assignments and propagates unknowns" {
  let expr = logic_normalize(
    LogicExpr::And([
      logic_symbol("A"),
      logic_normalize(LogicExpr::Not(logic_symbol("B"))),
    ]),
  )
  let assignments1 : Array[(String, Bool)] = Array::new()
  assignments1.push(("A", true))
  assignments1.push(("B", false))
  assert_eq(logic_eval(expr.copy(), assignments1), Some(true))
  let assignments2 : Array[(String, Bool)] = Array::new()
  assignments2.push(("A", true))
  assert_eq(logic_eval(expr, assignments2), None)
}

///|
test "logic_and matches boolean conjunction truth table" {
  let x = logic_symbol("x")
  let y = logic_symbol("y")
  let expr = logic_normalize(LogicExpr::And([x.copy(), y.copy()]))
  let both_true : Array[(String, Bool)] = [("x", true), ("y", true)]
  assert_eq(logic_eval(expr.copy(), both_true), Some(true))
  let second_false : Array[(String, Bool)] = [("x", true), ("y", false)]
  assert_eq(logic_eval(expr, second_false), Some(false))
}

///|
test "logic_ite simplifies boolean branches" {
  let cond = logic_symbol("Cond")
  let direct = logic_ite(cond.copy(), logic_true(), logic_false())
  assert_eq(direct, cond)
  let negated = logic_ite(cond.copy(), logic_false(), logic_true())
  match negated {
    Not(inner) => assert_eq(inner, cond)
    _ => abort("expected negated condition")
  }
}

///|
test "logic_ite evaluates according to assignments" {
  let cond = logic_symbol("Cond")
  let then_branch = logic_symbol("Then")
  let else_branch = logic_symbol("Else")
  let expr = logic_ite(cond.copy(), then_branch.copy(), else_branch.copy())
  let mut env_true : Array[(String, Bool)] = Array::new()
  env_true.push(("Cond", true))
  env_true.push(("Then", true))
  env_true.push(("Else", false))
  assert_eq(logic_eval(expr.copy(), env_true), Some(true))
  let mut env_false : Array[(String, Bool)] = Array::new()
  env_false.push(("Cond", false))
  env_false.push(("Then", true))
  env_false.push(("Else", true))
  assert_eq(logic_eval(expr, env_false), Some(true))
}
