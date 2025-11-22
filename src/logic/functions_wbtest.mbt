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
    Some(model) => {
      assert_eq(model.length(), 2)
      assert_contains_assignment(model, "x", true)
      assert_contains_assignment(model, "y", true)
    }
    None => abort("expected satisfiable")
  }
  let models = logic_all_satisfying_assignments(expr.copy())
  assert_eq(models.length(), 1)
  assert_contains_assignment(models[0], "x", true)
  assert_contains_assignment(models[0], "y", true)
  let tautology = logic_implies(
    logic_and([x.copy(), logic_implies(x.copy(), y.copy())]),
    y.copy(),
  )
  assert_eq(logic_satisfiable(logic_not(tautology)), None)
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
