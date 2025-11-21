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
