///|
test "logic_and simplifies nested expressions" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let expr = logic_and([
    a.copy(),
    logic_true(),
    logic_and([b.copy(), logic_true()]),
  ])
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
  let contradiction = logic_and([a.copy(), logic_not(a.copy())])
  assert_eq(contradiction, logic_false())
}

///|
test "logic_and canonicalizes operand order" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let expr1 = logic_and([a.copy(), b.copy()])
  let expr2 = logic_and([b, a])
  assert_eq(expr1, expr2)
}

///|
test "logic_or short circuits and detects tautologies" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let expr = logic_or([
    logic_false(),
    a.copy(),
    logic_or([b.copy(), logic_false()]),
  ])
  match expr {
    Or(terms) => assert_eq(terms.length(), 2)
    _ => abort("expected disjunction")
  }
  let tautology = logic_or([a.copy(), logic_not(a.copy())])
  assert_eq(tautology, logic_true())
}

///|
test "logic_or canonicalizes operand order" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let expr1 = logic_or([a.copy(), b.copy()])
  let expr2 = logic_or([b, a])
  assert_eq(expr1, expr2)
}

///|
test "logic_xor cancels duplicates and tracks parity" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let reduced = logic_xor([a.copy(), a.copy(), b.copy()])
  assert_eq(reduced, b)
  let toggled = logic_xor([a.copy(), logic_true()])
  match toggled {
    Not(inner) => assert_eq(inner, a)
    _ => abort("expected negated symbol")
  }
}

///|
test "logic_xor canonicalizes operand order" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let expr1 = logic_xor([a.copy(), b.copy()])
  let expr2 = logic_xor([b, a])
  assert_eq(expr1, expr2)
}

///|
test "logic_implies and equivalent follow boolean identities" {
  let a = logic_symbol("A")
  let implication = logic_implies(a.copy(), a.copy())
  assert_eq(implication, logic_true())
  let negated = logic_implies(a.copy(), logic_false())
  match negated {
    Not(inner) => assert_eq(inner, a)
    _ => abort("expected negated antecedent")
  }
  let equivalence = logic_equivalent(a.copy(), a.copy())
  assert_eq(equivalence, logic_true())
}

///|
test "logic_eval resolves assignments and propagates unknowns" {
  let expr = logic_and([logic_symbol("A"), logic_not(logic_symbol("B"))])
  let assignments1 : Array[(String, Bool)] = Array::new()
  assignments1.push(("A", true))
  assignments1.push(("B", false))
  assert_eq(logic_eval(expr.copy(), assignments1), Some(true))
  let assignments2 : Array[(String, Bool)] = Array::new()
  assignments2.push(("A", true))
  assert_eq(logic_eval(expr, assignments2), None)
}
