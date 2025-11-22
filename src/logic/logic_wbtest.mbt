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
  let env_true : Array[(String, Bool)] = Array::new()
  env_true.push(("Cond", true))
  env_true.push(("Then", true))
  env_true.push(("Else", false))
  assert_eq(logic_eval(expr.copy(), env_true), Some(true))
  let env_false : Array[(String, Bool)] = Array::new()
  env_false.push(("Cond", false))
  env_false.push(("Then", true))
  env_false.push(("Else", true))
  assert_eq(logic_eval(expr, env_false), Some(true))
}

///|
test "logic_collect_variables returns sorted unique names" {
  let expr = logic_normalize(
    LogicExpr::And([
      logic_symbol("C"),
      logic_normalize(
        LogicExpr::Or([
          logic_symbol("A"),
          logic_normalize(LogicExpr::Not(logic_symbol("B"))),
        ]),
      ),
    ]),
  )
  let vars = logic_collect_variables(expr)
  assert_eq(vars, ["A", "B", "C"])
}

///|
test "logic_collect_subexpressions gathers each unique expression" {
  let expr = logic_normalize(
    LogicExpr::And([
      logic_symbol("A"),
      logic_normalize(LogicExpr::Or([logic_symbol("B"), logic_symbol("A")])),
    ]),
  )
  let subs = logic_collect_subexpressions(expr)
  assert_eq(subs.length(), 4)
  assert_contains_expr(subs, logic_symbol("A"))
  assert_contains_expr(subs, logic_symbol("B"))
  assert_contains_expr(
    subs,
    logic_normalize(LogicExpr::Or([logic_symbol("A"), logic_symbol("B")])),
  )
  assert_contains_expr(subs, expr)
}

///|
fn assert_contains_expr(
  expressions : Array[LogicExpr],
  target : LogicExpr,
) -> Unit {
  let len = expressions.length()
  let mut found = false
  for i in 0..<len {
    if expressions[i] == target {
      found = true
    }
  }
  if !found {
    abort("missing expected expression")
  }
}

///|
test "logic_expr_depth tracks maximum nesting" {
  let expr = logic_normalize(
    LogicExpr::And([
      logic_symbol("A"),
      logic_normalize(LogicExpr::Not(logic_symbol("B"))),
    ]),
  )
  assert_eq(logic_expr_depth(expr), 3)
  let conditional = logic_ite(
    logic_symbol("Cond"),
    logic_symbol("X"),
    logic_normalize(LogicExpr::And([logic_symbol("Y"), logic_symbol("Z")])),
  )
  assert_eq(logic_expr_depth(conditional), 3)
}

///|
test "logic_expr_complexity counts expression nodes" {
  let expr = logic_normalize(
    LogicExpr::And([
      logic_symbol("A"),
      logic_normalize(LogicExpr::Not(logic_symbol("B"))),
    ]),
  )
  assert_eq(logic_expr_complexity(expr), 4)
  let simple = logic_symbol("Flag")
  assert_eq(logic_expr_complexity(simple), 1)
}

///|
test "logic_to_dnf expands xor into canonical form" {
  let expr = logic_normalize(
    LogicExpr::Xor([logic_symbol("A"), logic_symbol("B")]),
  )
  let dnf = logic_to_dnf(expr)
  let expected = logic_normalize(
    LogicExpr::Or([
      logic_normalize(
        LogicExpr::And([
          logic_symbol("A"),
          logic_normalize(LogicExpr::Not(logic_symbol("B"))),
        ]),
      ),
      logic_normalize(
        LogicExpr::And([
          logic_normalize(LogicExpr::Not(logic_symbol("A"))),
          logic_symbol("B"),
        ]),
      ),
    ]),
  )
  assert_eq(dnf, expected)
}

///|
test "logic_to_dnf preserves implication semantics" {
  let expr = logic_normalize(
    LogicExpr::Implies(logic_symbol("P"), logic_symbol("Q")),
  )
  let dnf = logic_to_dnf(expr.copy())
  assert_equivalent(dnf, expr)
}

///|
test "logic_to_cnf expands xor into conjunction of disjunctions" {
  let expr = logic_normalize(
    LogicExpr::Xor([logic_symbol("A"), logic_symbol("B")]),
  )
  let cnf = logic_to_cnf(expr.copy())
  assert_equivalent(cnf, expr)
}

///|
test "logic_to_cnf matches implication behavior" {
  let expr = logic_normalize(
    LogicExpr::Implies(logic_symbol("P"), logic_symbol("Q")),
  )
  let cnf = logic_to_cnf(expr.copy())
  assert_equivalent(cnf, expr)
}

///|
test "logic_simplify_logic dispatches to requested form" {
  let expr = logic_normalize(
    LogicExpr::Or([
      logic_normalize(LogicExpr::And([logic_symbol("X"), logic_symbol("Y")])),
      logic_normalize(
        LogicExpr::And([
          logic_symbol("X"),
          logic_normalize(LogicExpr::Not(logic_symbol("Y"))),
        ]),
      ),
      logic_normalize(
        LogicExpr::And([
          logic_normalize(LogicExpr::Not(logic_symbol("X"))),
          logic_symbol("Z"),
        ]),
      ),
    ]),
  )
  let dnf = logic_simplify_logic(expr.copy(), "dnf")
  assert_eq(dnf, logic_to_dnf(expr.copy()))
  let cnf = logic_simplify_logic(expr.copy(), "cnf")
  assert_equivalent(cnf, logic_to_cnf(expr.copy()))
}

///|
test "logic_simplify_logic with both chooses lower complexity" {
  let expr = logic_normalize(
    LogicExpr::Implies(logic_symbol("P"), logic_symbol("Q")),
  )
  let simplified = logic_simplify_logic(expr.copy(), "both")
  let dnf = logic_to_dnf(expr.copy())
  let cnf = logic_to_cnf(expr.copy())
  let dnf_cost = logic_expr_complexity(dnf.copy())
  let cnf_cost = logic_expr_complexity(cnf.copy())
  let expected_cost = if cnf_cost < dnf_cost { cnf_cost } else { dnf_cost }
  assert_eq(logic_expr_complexity(simplified), expected_cost)
}

///|
test "gate primitives implement boolean truth tables" {
  assert_eq(gate_not(true), false)
  assert_eq(gate_not(false), true)
  assert_eq(gate_and([true, true, true]), true)
  assert_eq(gate_and([true, false, true]), false)
  assert_eq(gate_or([false, false]), false)
  assert_eq(gate_or([false, true]), true)
  assert_eq(gate_nand([true, true]), false)
  assert_eq(gate_nand([true, false]), true)
  assert_eq(gate_nor([false, false, false]), true)
  assert_eq(gate_nor([false, true]), false)
  assert_eq(gate_xor([true, true, false]), false)
  assert_eq(gate_xor([true, false, false]), true)
  assert_eq(gate_xnor([true, true]), true)
  assert_eq(gate_xnor([true, false]), false)
}

///|
fn assert_equivalent(lhs : LogicExpr, rhs : LogicExpr) -> Unit {
  let vars = merge_variables(lhs.copy(), rhs.copy())
  let count = vars.length()
  let total = pow_two_test(count)
  let mut index = 0
  while index < total {
    let assignment_bools = assignment_from_index_test(index, count)
    let env = build_env(vars, assignment_bools)
    let lhs_val = logic_eval(lhs.copy(), env)
    let rhs_val = logic_eval(rhs.copy(), env)
    match (lhs_val, rhs_val) {
      (Some(a), Some(b)) => if a != b { abort("expressions not equivalent") }
      _ => abort("unexpected None in equivalence check")
    }
    index += 1
  }
}

///|
fn merge_variables(a : LogicExpr, b : LogicExpr) -> Array[String] {
  let names = logic_collect_variables(a)
  let (_, merged) = collect_vars_from_expr(b, names)
  merged
}

///|
fn collect_vars_from_expr(
  expr : LogicExpr,
  names : Array[String],
) -> (Map[String, Bool], Array[String]) {
  let seen : Map[String, Bool] = {}
  let collected = names
  let len = collected.length()
  let mut i = 0
  while i < len {
    seen.set(collected[i], true)
    i += 1
  }
  let (_, final_names) = collect_variables_internal(expr, seen, collected)
  (seen, final_names)
}

///|
fn build_env(
  names : Array[String],
  values : Array[Bool],
) -> Array[(String, Bool)] {
  let len = names.length()
  let env = Array::new(capacity=len)
  let mut i = 0
  while i < len {
    env.push((names[i], values[i]))
    i += 1
  }
  env
}

///|
fn pow_two_test(exp : Int) -> Int {
  let mut result = 1
  let mut i = 0
  while i < exp {
    result = result * 2
    i += 1
  }
  result
}

///|
fn assignment_from_index_test(index : Int, count : Int) -> Array[Bool] {
  let assignment = Array::new(capacity=count)
  let mut remaining = index
  let mut i = 0
  while i < count {
    assignment.push(remaining % 2 != 0)
    remaining = remaining / 2
    i += 1
  }
  assignment
}
