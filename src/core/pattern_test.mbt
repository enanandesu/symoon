///|
fn unwrap_binding(bindings : PatternBindings, name : String) -> Expr {
  match PatternBindings::get(bindings, name) {
    Some(expr) => expr
    None => abort("missing binding: " + name)
  }
}

///|
test "pattern wildcard binding captures operand" {
  let expr = add(sym("x"), int(2))
  let pattern = pattern_binary(pattern_wildcard("lhs"), pattern_int())
  match match_expr(pattern, expr) {
    Some(bindings) => {
      let bound = unwrap_binding(bindings, "lhs")
      inspect(bound, content="x")
    }
    None => abort("expected wildcard match")
  }
}

///|
test "pattern guarded wildcard enforces predicate" {
  let positive_guard = pattern_guarded("value", (candidate : Expr) => match
    candidate {
    Expr::Int(n) => n > 0
    _ => false
  })
  assert_eq(matches(positive_guard, int(5)), true)
  assert_eq(matches(positive_guard, int(-2)), false)
  assert_eq(matches(positive_guard, sym("x")), false)
}

///|
test "pattern one of selects matching branch" {
  let variant = pattern_one_of([pattern_symbol(name=Some("y")), pattern_int()])
  assert_eq(matches(variant, sym("y")), true)
  assert_eq(matches(variant, int(10)), true)
  assert_eq(matches(variant, sym("z")), false)
}

///|
test "rewrite applies rule repeatedly" {
  let add_pattern = pattern_guard(
    pattern_binary(pattern_wildcard("expr"), pattern_int(value=Some(0))),
    (candidate : Expr, _ : PatternBindings) => match candidate {
      Expr::Binary(BinaryOp::Add, _, _) => true
      _ => false
    },
  )
  let add_zero_rule = RewriteRule::new(add_pattern, (bindings : PatternBindings) => unwrap_binding(
    bindings, "expr",
  ))
  let expr = add(sym("x"), int(0))
  let rules : Array[RewriteRule] = Array::new(capacity=1)
  rules.push(add_zero_rule)
  let simplified = rewrite(expr, rules)
  inspect(simplified, content="x")
  let nested = add(add(sym("x"), int(0)), int(0))
  let more_rules : Array[RewriteRule] = Array::new(capacity=1)
  more_rules.push(add_zero_rule)
  let simplified_nested = rewrite(nested, more_rules, max_iterations=4)
  inspect(simplified_nested, content="x")
}
