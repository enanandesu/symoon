///|
test "fo_eval handles quantifiers and predicates" {
  let domain : Array[String] = ["Alice", "Bob"]
  let student_pred = fo_predicate(1, args => args[0] != "Bob")
  let equals_pred = fo_predicate(2, args => args[0] == args[1])
  let context = fo_interpretation(domain)
    .with_predicate("Student", student_pred)
    .with_predicate("Equals", equals_pred)
  let forall_expr = FOFormula::ForAll(
    "x",
    FOFormula::Predicate("Student", [fo_var("x")]),
  )
  assert_eq(fo_eval(forall_expr, context.copy()), Some(false))
  let exists_expr = FOFormula::Exists(
    "x",
    FOFormula::Predicate("Student", [fo_var("x")]),
  )
  assert_eq(fo_eval(exists_expr, context.copy()), Some(true))
  let relation = FOFormula::Exists(
    "y",
    FOFormula::Predicate("Equals", [fo_var("y"), fo_const("Alice")]),
  )
  let combined = FOFormula::ForAll("x", relation)
  assert_eq(fo_eval(combined, context), Some(true))
}

///|
test "fo_eval_with_assignments respects free variables" {
  let domain : Array[String] = ["Alice"]
  let student_pred = fo_predicate(1, args => args[0] == "Alice")
  let context = fo_interpretation(domain).with_predicate("Student", student_pred)
  let free_expr = FOFormula::Predicate("Student", [fo_var("z")])
  assert_eq(fo_eval(free_expr.copy(), context.copy()), None)
  let assignments : Array[(String, String)] = [("z", "Alice")]
  assert_eq(fo_eval_with_assignments(free_expr, context, assignments), Some(true))
}
