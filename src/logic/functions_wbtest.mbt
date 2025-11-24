///|
test "logic_from_truth_table builds xor behavior" {
  let vars : Array[String] = ["A", "B"]
  let table : Array[(Array[Bool], Bool)] = [
    ([false, false], false),
    ([false, true], true),
    ([true, false], true),
    ([true, true], false),
  ]
  let expr = logic_from_truth_table(vars, table)
  let env1 : Array[(String, Bool)] = [("A", false), ("B", true)]
  assert_eq(logic_eval(expr.copy(), env1), Some(true))
  let env2 : Array[(String, Bool)] = [("A", true), ("B", true)]
  assert_eq(logic_eval(expr, env2), Some(false))
}

///|
test "logic_from_truth_table handles constants and zero vars" {
  let single_var : Array[String] = ["Flag"]
  let table_false : Array[(Array[Bool], Bool)] = [
    ([false], false),
    ([true], false),
  ]
  let always_false = logic_from_truth_table(single_var, table_false)
  assert_eq(always_false, logic_false())
  let zero_vars : Array[String] = []
  let table_true : Array[(Array[Bool], Bool)] = [([], true)]
  let constant_true = logic_from_truth_table(zero_vars, table_true)
  assert_eq(constant_true, logic_true())
}

///|
test "logic_truth_table builds xor rows and formats lines" {
  let vars : Array[String] = ["x", "y"]
  let expr = logic_xor([logic_symbol("x"), logic_symbol("y")])
  let rows = logic_truth_table(expr.copy(), vars)
  assert_eq(rows.length(), 4)
  assert_eq(rows[0], ([false, false], Some(false)))
  assert_eq(rows[1], ([true, false], Some(true)))
  assert_eq(rows[2], ([false, true], Some(true)))
  assert_eq(rows[3], ([true, true], Some(false)))
  let lines = logic_truth_table_lines(expr, vars)
  assert_eq(lines, [
    "[false, false] -> false", "[true, false] -> true", "[false, true] -> true",
    "[true, true] -> false",
  ])
}

///|
test "logic_satisfiable finds one model and all models" {
  let x = logic_symbol("x")
  let y = logic_symbol("y")
  let expr = logic_and([x.copy(), logic_or([logic_not(x.copy()), y.copy()])])
  match logic_satisfiable(expr.copy()) {
    LogicSatResult::Model(model) => {
      assert_eq(model.length(), 2)
      assert_contains_assignment(model, "x", true)
      assert_contains_assignment(model, "y", true)
    }
    _ => abort("expected satisfiable")
  }
  match logic_satisfiable(expr.copy(), all_models=true) {
    LogicSatResult::AllModels(models) => {
      assert_eq(models.length(), 1)
      assert_contains_assignment(models[0], "x", true)
      assert_contains_assignment(models[0], "y", true)
    }
    LogicSatResult::Unsatisfiable => abort("expected all models result")
    LogicSatResult::Model(_) => abort("expected aggregated models")
  }
  let models = logic_all_satisfying_assignments(expr.copy())
  assert_eq(models.length(), 1)
  assert_contains_assignment(models[0], "x", true)
  assert_contains_assignment(models[0], "y", true)
  let tautology = logic_implies(
    logic_and([x.copy(), logic_implies(x.copy(), y.copy())]),
    y.copy(),
  )
  assert_eq(
    logic_satisfiable(logic_not(tautology)),
    LogicSatResult::Unsatisfiable,
  )
  match logic_satisfiable(logic_not(tautology), all_models=true) {
    LogicSatResult::Unsatisfiable => ()
    _ => abort("expected unsatisfiable when enumerating models")
  }
}

///|
test "logic_is_tautology verifies equivalences and De Morgan" {
  let x = logic_symbol("x")
  let y = logic_symbol("y")
  let left = logic_implies(x.copy(), y.copy())
  let right = logic_or([logic_not(x.copy()), y.copy()])
  let equivalence = logic_equivalent(left.copy(), right.copy())
  assert_eq(logic_is_tautology(equivalence.copy()), true)
  assert_eq(logic_equivalent_expr(left, right), true)
  let demorgan_left = logic_not(logic_and([x.copy(), y.copy()]))
  let demorgan_right = logic_or([logic_not(x.copy()), logic_not(y.copy())])
  assert_eq(
    logic_equivalent_expr(demorgan_left.copy(), demorgan_right.copy()),
    true,
  )
  let demorgan_equivalence = logic_equivalent(demorgan_left, demorgan_right)
  assert_eq(logic_is_tautology(demorgan_equivalence), true)
}

///|
test "logic_distribute_and_over_or expands to disjunction of conjunctions" {
  let x = logic_symbol("x")
  let y = logic_symbol("y")
  let z = logic_symbol("z")
  let expr = logic_and([logic_or([x.copy(), y.copy()]), z.copy()])
  let distributed = logic_distribute_and_over_or(expr.copy())
  let expected = logic_or([
    logic_and([x.copy(), z.copy()]),
    logic_and([y.copy(), z.copy()]),
  ])
  assert_eq(distributed, expected)
  assert_eq(logic_equivalent_expr(expr, distributed), true)
}

///|
test "logic_distribute_or_over_and expands to conjunction of disjunctions" {
  let a = logic_symbol("a")
  let b = logic_symbol("b")
  let c = logic_symbol("c")
  let expr = logic_or([logic_and([a.copy(), b.copy()]), c.copy()])
  let distributed = logic_distribute_or_over_and(expr.copy())
  let expected = logic_and([
    logic_or([a.copy(), c.copy()]),
    logic_or([b.copy(), c.copy()]),
  ])
  assert_eq(distributed, expected)
  assert_eq(logic_equivalent_expr(expr, distributed), true)
}

///|
test "logic_equivalent_expr validates absorption law" {
  let a = logic_symbol("a")
  let b = logic_symbol("b")
  let absorption_left = logic_and([a.copy(), logic_or([a.copy(), b.copy()])])
  let absorption_right = a.copy()
  assert_eq(logic_equivalent_expr(absorption_left, absorption_right), true)
  let absorption_or_left = logic_or([a.copy(), logic_and([a.copy(), b.copy()])])
  assert_eq(logic_equivalent_expr(absorption_or_left, absorption_right), true)
}

///|
test "logic_probability computes Bernoulli combinations" {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let c = logic_symbol("C")
  let probs : Array[(String, Double)] = [("A", 0.6), ("B", 0.3), ("C", 0.8)]
  let and_prob = logic_probability(logic_and([a.copy(), b.copy()]), probs)
  assert_close(and_prob, 0.18, 0.000000001)
  let or_prob = logic_probability(logic_or([a.copy(), b.copy()]), probs)
  assert_close(or_prob, 0.72, 0.000000001)
  let implies_prob = logic_probability(logic_implies(a.copy(), b.copy()), probs)
  assert_close(implies_prob, 0.58, 0.000000001)
  let xor_prob = logic_probability(
    logic_xor([a.copy(), b.copy(), c.copy()]),
    probs,
  )
  assert_close(xor_prob, 0.476, 0.000000001)
  let cond_prob = logic_conditional_probability(a.copy(), b.copy(), probs)
  assert_close(cond_prob, 0.6, 0.000000001)
}

///|
test "logic_parse_and_serialize round trips and matches structure" {
  let expr_str = "x & y | ~z"
  let parsed = logic_parse(expr_str)
  let expected = logic_or([
    logic_and([logic_symbol("x"), logic_symbol("y")]),
    logic_not(logic_symbol("z")),
  ])
  assert_eq(parsed, expected)
  let serialized = logic_serialize(parsed.copy())
  let restored = logic_deserialize(serialized)
  assert_eq(restored, parsed)
  assert_eq(logic_equivalent_expr(parsed, restored), true)
}

///|
test "logic_parse honors precedence and parentheses" {
  let expr_str = "a | b & ~(c ^ d)"
  let parsed = logic_parse(expr_str)
  let expected = logic_or([
    logic_symbol("a"),
    logic_and([
      logic_symbol("b"),
      logic_not(logic_xor([logic_symbol("c"), logic_symbol("d")])),
    ]),
  ])
  assert_eq(parsed, expected)
  let roundtrip = logic_deserialize(logic_serialize(parsed.copy()))
  assert_eq(roundtrip, expected)
}

///|
test "logic_deserialize parses serialized text directly" {
  let text = "And(Symbol(p),Or(Not(Symbol(q)),Symbol(r)))"
  let expr = logic_deserialize(text)
  let expected = logic_and([
    logic_symbol("p"),
    logic_or([logic_not(logic_symbol("q")), logic_symbol("r")]),
  ])
  assert_eq(expr, expected)
}

///|
test "logic_gate_model builds and simplifies circuit" {
  let circuit = logic_gate_model()
  let expected = logic_and([logic_symbol("A"), logic_symbol("B")])
  assert_eq(logic_equivalent_expr(circuit.copy(), expected.copy()), true)
  assert_eq(logic_simplify(circuit.copy()), expected)
  let env1 : Array[(String, Bool)] = [("A", true), ("B", true), ("C", false)]
  assert_eq(logic_eval(circuit.copy(), env1), Some(true))
  let env2 : Array[(String, Bool)] = [("A", true), ("B", false), ("C", true)]
  assert_eq(logic_eval(circuit, env2), Some(false))
}

///|
test "logic_half_adder truth table" {
  let a = logic_symbol("a")
  let b = logic_symbol("b")
  let (sum_bit, carry_bit) = logic_half_adder(a, b)
  assert_eq(
    logic_eval(sum_bit.copy(), [("a", false), ("b", false)]),
    Some(false),
  )
  assert_eq(
    logic_eval(carry_bit.copy(), [("a", false), ("b", false)]),
    Some(false),
  )
  assert_eq(logic_eval(sum_bit.copy(), [("a", true), ("b", false)]), Some(true))
  assert_eq(
    logic_eval(carry_bit.copy(), [("a", true), ("b", false)]),
    Some(false),
  )
  assert_eq(logic_eval(sum_bit.copy(), [("a", false), ("b", true)]), Some(true))
  assert_eq(
    logic_eval(carry_bit.copy(), [("a", false), ("b", true)]),
    Some(false),
  )
  assert_eq(logic_eval(sum_bit.copy(), [("a", true), ("b", true)]), Some(false))
  assert_eq(logic_eval(carry_bit, [("a", true), ("b", true)]), Some(true))
}

///|
test "logic_full_adder truth table" {
  let a = logic_symbol("a")
  let b = logic_symbol("b")
  let cin = logic_symbol("cin")
  let (sum_out, carry_out) = logic_full_adder(a, b, cin)
  assert_full_adder(
    sum_out.copy(),
    carry_out.copy(),
    false,
    false,
    false,
    false,
    false,
  )
  assert_full_adder(
    sum_out.copy(),
    carry_out.copy(),
    true,
    false,
    false,
    true,
    false,
  )
  assert_full_adder(
    sum_out.copy(),
    carry_out.copy(),
    false,
    true,
    false,
    true,
    false,
  )
  assert_full_adder(
    sum_out.copy(),
    carry_out.copy(),
    true,
    true,
    false,
    false,
    true,
  )
  assert_full_adder(
    sum_out.copy(),
    carry_out.copy(),
    false,
    false,
    true,
    true,
    false,
  )
  assert_full_adder(
    sum_out.copy(),
    carry_out.copy(),
    true,
    false,
    true,
    false,
    true,
  )
  assert_full_adder(
    sum_out.copy(),
    carry_out.copy(),
    false,
    true,
    true,
    false,
    true,
  )
  assert_full_adder(sum_out, carry_out, true, true, true, true, true)
}

///|
fn assert_contains_assignment(
  env : Array[(String, Bool)],
  name : String,
  value : Bool,
) -> Unit {
  let len = env.length()
  let mut found = false
  for i in 0..<len {
    let (key, val) = env[i]
    if key == name && val == value {
      found = true
    }
  }
  if !found {
    abort("missing expected assignment")
  }
}

///|
fn assert_full_adder(
  sum_expr : LogicExpr,
  carry_expr : LogicExpr,
  a_val : Bool,
  b_val : Bool,
  cin_val : Bool,
  expected_sum : Bool,
  expected_carry : Bool,
) -> Unit raise {
  let env : Array[(String, Bool)] = [
    ("a", a_val),
    ("b", b_val),
    ("cin", cin_val),
  ]
  assert_eq(logic_eval(sum_expr.copy(), env), Some(expected_sum))
  assert_eq(logic_eval(carry_expr, env), Some(expected_carry))
}

///|
fn assert_close(actual : Double, expected : Double, tolerance : Double) -> Unit {
  let diff = if actual > expected {
    actual - expected
  } else {
    expected - actual
  }
  if diff > tolerance {
    abort("values differ more than tolerance")
  }
}
