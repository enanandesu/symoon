///|
fn unwrap_binding(bindings : PatternBindings, name : String) -> Expr {
  match PatternBindings::get(bindings, name) {
    Some(expr) => expr
    None => abort("missing binding: " + name)
  }
}

///|
fn pow_root_guard(_expr : Expr, bindings : PatternBindings) -> Bool {
  match PatternBindings::get(bindings, "n_expr") {
    Some(Expr::Int(value)) => value > 0
    _ => false
  }
}

///|
fn identity_rewrite_rules() -> Array[RewriteRule] {
  let rules : Array[RewriteRule] = Array::new()
  let pow_root_pattern = pattern_guard(
    pattern_binary(
      pattern_binary(
        pattern_wildcard("inner_base"),
        pattern_wildcard("n_expr"),
        op=Some(BinaryOp::Pow),
      ),
      pattern_binary(
        pattern_int(value=Some(1)),
        pattern_wildcard("n_expr"),
        op=Some(BinaryOp::Div),
      ),
      op=Some(BinaryOp::Pow),
    ),
    pow_root_guard,
  )
  let pow_root_rule = RewriteRule::new(pow_root_pattern, (
    bindings : PatternBindings,
  ) => {
    let base_expr = unwrap_binding(bindings.copy(), "inner_base")
    let exponent_expr = unwrap_binding(bindings, "n_expr")
    match exponent_expr {
      Expr::Int(value) =>
        if value % 2 == 0 {
          abs(base_expr)
        } else {
          base_expr
        }
      _ => base_expr
    }
  })
  rules.push(pow_root_rule)
  let log_exp_pattern = pattern_unary(
    pattern_unary(pattern_wildcard("inner"), op=Some(UnaryOp::Exp)),
    op=Some(UnaryOp::Log),
  )
  rules.push(
    RewriteRule::new(log_exp_pattern, (bindings : PatternBindings) => unwrap_binding(
      bindings, "inner",
    )),
  )
  let exp_log_pattern = pattern_unary(
    pattern_unary(pattern_wildcard("inner"), op=Some(UnaryOp::Log)),
    op=Some(UnaryOp::Exp),
  )
  rules.push(
    RewriteRule::new(exp_log_pattern, (bindings : PatternBindings) => unwrap_binding(
      bindings, "inner",
    )),
  )
  let log_add_pattern = pattern_binary(
    pattern_unary(pattern_wildcard("log_a"), op=Some(UnaryOp::Log)),
    pattern_unary(pattern_wildcard("log_b"), op=Some(UnaryOp::Log)),
    op=Some(BinaryOp::Add),
  )
  rules.push(
    RewriteRule::new(log_add_pattern, (bindings : PatternBindings) => {
      let a = unwrap_binding(bindings.copy(), "log_a")
      let b = unwrap_binding(bindings, "log_b")
      log(mul(a, b))
    }),
  )
  let log_sub_pattern = pattern_binary(
    pattern_unary(pattern_wildcard("log_a"), op=Some(UnaryOp::Log)),
    pattern_unary(pattern_wildcard("log_b"), op=Some(UnaryOp::Log)),
    op=Some(BinaryOp::Sub),
  )
  rules.push(
    RewriteRule::new(log_sub_pattern, (bindings : PatternBindings) => {
      let a = unwrap_binding(bindings.copy(), "log_a")
      let b = unwrap_binding(bindings, "log_b")
      log(div(a, b))
    }),
  )
  let one_literal = pattern_int(value=Some(1))
  let two_literal = pattern_int(value=Some(2))
  let neg_two_literal = pattern_int(value=Some(-2))
  let py_theta = pattern_wildcard("py_theta")
  let sin_py = pattern_unary(py_theta.copy(), op=Some(UnaryOp::Sin))
  let cos_py = pattern_unary(py_theta.copy(), op=Some(UnaryOp::Cos))
  let sin_sq = pattern_binary(
    sin_py.copy(),
    two_literal.copy(),
    op=Some(BinaryOp::Pow),
  )
  let cos_sq = pattern_binary(
    cos_py.copy(),
    two_literal.copy(),
    op=Some(BinaryOp::Pow),
  )
  let sin_sq_plus_cos_sq = pattern_binary(
    sin_sq.copy(),
    cos_sq.copy(),
    op=Some(BinaryOp::Add),
  )
  rules.push(
    RewriteRule::new(sin_sq_plus_cos_sq, (_ : PatternBindings) => int(1)),
  )
  let cos_sq_plus_sin_sq = pattern_binary(
    cos_sq.copy(),
    sin_sq.copy(),
    op=Some(BinaryOp::Add),
  )
  rules.push(
    RewriteRule::new(cos_sq_plus_sin_sq, (_ : PatternBindings) => int(1)),
  )
  let cos_sq_minus_sin_sq = pattern_binary(
    cos_sq.copy(),
    sin_sq.copy(),
    op=Some(BinaryOp::Sub),
  )
  rules.push(
    RewriteRule::new(cos_sq_minus_sin_sq, (bindings : PatternBindings) => {
      let angle = unwrap_binding(bindings, "py_theta")
      cos(mul(int(2), angle))
    }),
  )
  let sin_sq_minus_cos_sq = pattern_binary(
    sin_sq.copy(),
    cos_sq.copy(),
    op=Some(BinaryOp::Sub),
  )
  rules.push(
    RewriteRule::new(sin_sq_minus_cos_sq, (bindings : PatternBindings) => {
      let angle = unwrap_binding(bindings, "py_theta")
      neg(cos(mul(int(2), angle)))
    }),
  )
  let tan_theta = pattern_wildcard("tan_theta")
  let tan_expr = pattern_unary(tan_theta.copy(), op=Some(UnaryOp::Tan))
  let tan_sq = pattern_binary(
    tan_expr.copy(),
    two_literal.copy(),
    op=Some(BinaryOp::Pow),
  )
  let tan_neg_sq = pattern_binary(
    tan_expr.copy(),
    neg_two_literal.copy(),
    op=Some(BinaryOp::Pow),
  )
  let one_plus_tan_sq = pattern_binary(
    one_literal.copy(),
    tan_sq.copy(),
    op=Some(BinaryOp::Add),
  )
  rules.push(
    RewriteRule::new(one_plus_tan_sq, (bindings : PatternBindings) => {
      let angle = unwrap_binding(bindings, "tan_theta")
      pow(cos(angle), int(-2))
    }),
  )
  let tan_sq_plus_one = pattern_binary(
    tan_sq.copy(),
    one_literal.copy(),
    op=Some(BinaryOp::Add),
  )
  rules.push(
    RewriteRule::new(tan_sq_plus_one, (bindings : PatternBindings) => {
      let angle = unwrap_binding(bindings, "tan_theta")
      pow(cos(angle), int(-2))
    }),
  )
  let one_plus_tan_neg_sq = pattern_binary(
    one_literal.copy(),
    tan_neg_sq.copy(),
    op=Some(BinaryOp::Add),
  )
  rules.push(
    RewriteRule::new(one_plus_tan_neg_sq, (bindings : PatternBindings) => {
      let angle = unwrap_binding(bindings, "tan_theta")
      pow(sin(angle), int(-2))
    }),
  )
  let tan_neg_sq_plus_one = pattern_binary(
    tan_neg_sq.copy(),
    one_literal.copy(),
    op=Some(BinaryOp::Add),
  )
  rules.push(
    RewriteRule::new(tan_neg_sq_plus_one, (bindings : PatternBindings) => {
      let angle = unwrap_binding(bindings, "tan_theta")
      pow(sin(angle), int(-2))
    }),
  )
  let tan_sq_div = pattern_binary(
    one_literal.copy(),
    pattern_binary(tan_expr.copy(), two_literal.copy(), op=Some(BinaryOp::Pow)),
    op=Some(BinaryOp::Div),
  )
  let one_plus_tan_sq_div = pattern_binary(
    one_literal.copy(),
    tan_sq_div.copy(),
    op=Some(BinaryOp::Add),
  )
  rules.push(
    RewriteRule::new(one_plus_tan_sq_div, (bindings : PatternBindings) => {
      let angle = unwrap_binding(bindings, "tan_theta")
      pow(sin(angle), int(-2))
    }),
  )
  let tan_sq_div_plus_one = pattern_binary(
    tan_sq_div.copy(),
    one_literal.copy(),
    op=Some(BinaryOp::Add),
  )
  rules.push(
    RewriteRule::new(tan_sq_div_plus_one, (bindings : PatternBindings) => {
      let angle = unwrap_binding(bindings, "tan_theta")
      pow(sin(angle), int(-2))
    }),
  )
  let tan_sum_a = pattern_wildcard("tan_sum_a")
  let tan_sum_b = pattern_wildcard("tan_sum_b")
  let tan_a = pattern_unary(tan_sum_a.copy(), op=Some(UnaryOp::Tan))
  let tan_b = pattern_unary(tan_sum_b.copy(), op=Some(UnaryOp::Tan))
  let tan_add_numer_options : Array[Pattern] = Array::new(capacity=2)
  tan_add_numer_options.push(
    pattern_binary(tan_a.copy(), tan_b.copy(), op=Some(BinaryOp::Add)),
  )
  tan_add_numer_options.push(
    pattern_binary(tan_b.copy(), tan_a.copy(), op=Some(BinaryOp::Add)),
  )
  let tan_add_numer = pattern_one_of(tan_add_numer_options)
  let tan_product_options : Array[Pattern] = Array::new(capacity=2)
  tan_product_options.push(
    pattern_binary(tan_a.copy(), tan_b.copy(), op=Some(BinaryOp::Mul)),
  )
  tan_product_options.push(
    pattern_binary(tan_b.copy(), tan_a.copy(), op=Some(BinaryOp::Mul)),
  )
  let tan_product = pattern_one_of(tan_product_options)
  let tan_add_denom = pattern_binary(
    one_literal.copy(),
    tan_product.copy(),
    op=Some(BinaryOp::Sub),
  )
  let tan_add_fraction = pattern_binary(
    tan_add_numer.copy(),
    tan_add_denom.copy(),
    op=Some(BinaryOp::Div),
  )
  rules.push(
    RewriteRule::new(tan_add_fraction, (bindings : PatternBindings) => {
      let a = unwrap_binding(bindings.copy(), "tan_sum_a")
      let b = unwrap_binding(bindings, "tan_sum_b")
      tan(add(a, b))
    }),
  )
  let tan_sub_numer_options : Array[Pattern] = Array::new(capacity=2)
  tan_sub_numer_options.push(
    pattern_binary(tan_a.copy(), tan_b.copy(), op=Some(BinaryOp::Sub)),
  )
  tan_sub_numer_options.push(
    pattern_binary(tan_b.copy(), tan_a.copy(), op=Some(BinaryOp::Sub)),
  )
  let tan_sub_numer = pattern_one_of(tan_sub_numer_options)
  let tan_sub_denom = pattern_binary(
    one_literal.copy(),
    tan_product.copy(),
    op=Some(BinaryOp::Add),
  )
  let tan_sub_fraction = pattern_binary(
    tan_sub_numer.copy(),
    tan_sub_denom.copy(),
    op=Some(BinaryOp::Div),
  )
  rules.push(
    RewriteRule::new(tan_sub_fraction, (bindings : PatternBindings) => {
      let a = unwrap_binding(bindings.copy(), "tan_sum_a")
      let b = unwrap_binding(bindings, "tan_sum_b")
      tan(sub(a, b))
    }),
  )
  let tan_double_num_options : Array[Pattern] = Array::new(capacity=2)
  tan_double_num_options.push(
    pattern_binary(two_literal.copy(), tan_expr.copy(), op=Some(BinaryOp::Mul)),
  )
  tan_double_num_options.push(
    pattern_binary(tan_expr.copy(), two_literal.copy(), op=Some(BinaryOp::Mul)),
  )
  let tan_double_num = pattern_one_of(tan_double_num_options)
  let tan_double_denom = pattern_binary(
    one_literal.copy(),
    tan_sq.copy(),
    op=Some(BinaryOp::Sub),
  )
  let tan_double_fraction = pattern_binary(
    tan_double_num.copy(),
    tan_double_denom.copy(),
    op=Some(BinaryOp::Div),
  )
  rules.push(
    RewriteRule::new(tan_double_fraction, (bindings : PatternBindings) => {
      let angle = unwrap_binding(bindings, "tan_theta")
      tan(mul(int(2), angle))
    }),
  )
  let sum_a = pattern_wildcard("sum_a")
  let sum_b = pattern_wildcard("sum_b")
  let sin_a_base = pattern_unary(sum_a.copy(), op=Some(UnaryOp::Sin))
  let cos_a_base = pattern_unary(sum_a.copy(), op=Some(UnaryOp::Cos))
  let sin_b_base = pattern_unary(sum_b.copy(), op=Some(UnaryOp::Sin))
  let cos_b_base = pattern_unary(sum_b.copy(), op=Some(UnaryOp::Cos))
  let sin_cos_options : Array[Pattern] = Array::new(capacity=2)
  sin_cos_options.push(
    pattern_binary(sin_a_base.copy(), cos_b_base.copy(), op=Some(BinaryOp::Mul)),
  )
  sin_cos_options.push(
    pattern_binary(cos_b_base.copy(), sin_a_base.copy(), op=Some(BinaryOp::Mul)),
  )
  let sin_a_cos_b = pattern_one_of(sin_cos_options)
  let cos_sin_options : Array[Pattern] = Array::new(capacity=2)
  cos_sin_options.push(
    pattern_binary(cos_a_base.copy(), sin_b_base.copy(), op=Some(BinaryOp::Mul)),
  )
  cos_sin_options.push(
    pattern_binary(sin_b_base.copy(), cos_a_base.copy(), op=Some(BinaryOp::Mul)),
  )
  let cos_a_sin_b = pattern_one_of(cos_sin_options)
  let cos_cos_options : Array[Pattern] = Array::new(capacity=2)
  cos_cos_options.push(
    pattern_binary(cos_a_base.copy(), cos_b_base.copy(), op=Some(BinaryOp::Mul)),
  )
  cos_cos_options.push(
    pattern_binary(cos_b_base.copy(), cos_a_base.copy(), op=Some(BinaryOp::Mul)),
  )
  let cos_a_cos_b = pattern_one_of(cos_cos_options)
  let sin_sin_options : Array[Pattern] = Array::new(capacity=2)
  sin_sin_options.push(
    pattern_binary(sin_a_base.copy(), sin_b_base.copy(), op=Some(BinaryOp::Mul)),
  )
  sin_sin_options.push(
    pattern_binary(sin_b_base.copy(), sin_a_base.copy(), op=Some(BinaryOp::Mul)),
  )
  let sin_a_sin_b = pattern_one_of(sin_sin_options)
  let sin_sum_pattern = pattern_binary(
    sin_a_cos_b.copy(),
    cos_a_sin_b.copy(),
    op=Some(BinaryOp::Add),
  )
  rules.push(
    RewriteRule::new(sin_sum_pattern, (bindings : PatternBindings) => {
      let a = unwrap_binding(bindings.copy(), "sum_a")
      let b = unwrap_binding(bindings, "sum_b")
      sin(add(a, b))
    }),
  )
  let sin_sum_pattern_swapped = pattern_binary(
    cos_a_sin_b.copy(),
    sin_a_cos_b.copy(),
    op=Some(BinaryOp::Add),
  )
  rules.push(
    RewriteRule::new(sin_sum_pattern_swapped, (bindings : PatternBindings) => {
      let a = unwrap_binding(bindings.copy(), "sum_a")
      let b = unwrap_binding(bindings, "sum_b")
      sin(add(a, b))
    }),
  )
  let sin_diff_pattern = pattern_binary(
    sin_a_cos_b.copy(),
    cos_a_sin_b.copy(),
    op=Some(BinaryOp::Sub),
  )
  rules.push(
    RewriteRule::new(sin_diff_pattern, (bindings : PatternBindings) => {
      let a = unwrap_binding(bindings.copy(), "sum_a")
      let b = unwrap_binding(bindings, "sum_b")
      sin(sub(a, b))
    }),
  )
  let sin_diff_pattern_swapped = pattern_binary(
    cos_a_sin_b.copy(),
    sin_a_cos_b.copy(),
    op=Some(BinaryOp::Sub),
  )
  rules.push(
    RewriteRule::new(sin_diff_pattern_swapped, (bindings : PatternBindings) => {
      let a = unwrap_binding(bindings.copy(), "sum_a")
      let b = unwrap_binding(bindings, "sum_b")
      sin(sub(b, a))
    }),
  )
  let sum_prod_primary = pattern_wildcard("sum_prod_primary")
  let sum_prod_secondary = pattern_wildcard("sum_prod_secondary")
  let sin_add_pattern = pattern_unary(
    pattern_binary(
      sum_prod_primary.copy(),
      sum_prod_secondary.copy(),
      op=Some(BinaryOp::Add),
    ),
    op=Some(UnaryOp::Sin),
  )
  let sin_sub_pattern = pattern_unary(
    pattern_binary(
      sum_prod_primary.copy(),
      sum_prod_secondary.copy(),
      op=Some(BinaryOp::Sub),
    ),
    op=Some(UnaryOp::Sin),
  )
  let cos_add_pattern = pattern_unary(
    pattern_binary(
      sum_prod_primary.copy(),
      sum_prod_secondary.copy(),
      op=Some(BinaryOp::Add),
    ),
    op=Some(UnaryOp::Cos),
  )
  let cos_sub_pattern = pattern_unary(
    pattern_binary(
      sum_prod_primary.copy(),
      sum_prod_secondary.copy(),
      op=Some(BinaryOp::Sub),
    ),
    op=Some(UnaryOp::Cos),
  )
  let sin_plus_special = pattern_binary(
    sin_add_pattern.copy(),
    sin_sub_pattern.copy(),
    op=Some(BinaryOp::Add),
  )
  let sin_plus_special_swapped = pattern_binary(
    sin_sub_pattern.copy(),
    sin_add_pattern.copy(),
    op=Some(BinaryOp::Add),
  )
  let sin_minus_special = pattern_binary(
    sin_add_pattern.copy(),
    sin_sub_pattern.copy(),
    op=Some(BinaryOp::Sub),
  )
  let sin_minus_special_swapped = pattern_binary(
    sin_sub_pattern.copy(),
    sin_add_pattern.copy(),
    op=Some(BinaryOp::Sub),
  )
  rules.push(
    RewriteRule::new(sin_plus_special, (bindings : PatternBindings) => {
      let primary = unwrap_binding(bindings.copy(), "sum_prod_primary")
      let secondary = unwrap_binding(bindings, "sum_prod_secondary")
      mul(int(2), mul(sin(primary.copy()), cos(secondary.copy())))
    }),
  )
  rules.push(
    RewriteRule::new(sin_plus_special_swapped, (bindings : PatternBindings) => {
      let primary = unwrap_binding(bindings.copy(), "sum_prod_primary")
      let secondary = unwrap_binding(bindings, "sum_prod_secondary")
      mul(int(2), mul(sin(primary.copy()), cos(secondary.copy())))
    }),
  )
  rules.push(
    RewriteRule::new(sin_minus_special, (bindings : PatternBindings) => {
      let primary = unwrap_binding(bindings.copy(), "sum_prod_primary")
      let secondary = unwrap_binding(bindings, "sum_prod_secondary")
      mul(int(2), mul(cos(primary.copy()), sin(secondary.copy())))
    }),
  )
  rules.push(
    RewriteRule::new(sin_minus_special_swapped, (bindings : PatternBindings) => {
      let primary = unwrap_binding(bindings.copy(), "sum_prod_primary")
      let secondary = unwrap_binding(bindings, "sum_prod_secondary")
      mul(int(-2), mul(cos(primary.copy()), sin(secondary.copy())))
    }),
  )
  let cos_plus_special = pattern_binary(
    cos_add_pattern.copy(),
    cos_sub_pattern.copy(),
    op=Some(BinaryOp::Add),
  )
  let cos_plus_special_swapped = pattern_binary(
    cos_sub_pattern.copy(),
    cos_add_pattern.copy(),
    op=Some(BinaryOp::Add),
  )
  let cos_minus_special = pattern_binary(
    cos_add_pattern.copy(),
    cos_sub_pattern.copy(),
    op=Some(BinaryOp::Sub),
  )
  let cos_minus_special_swapped = pattern_binary(
    cos_sub_pattern.copy(),
    cos_add_pattern.copy(),
    op=Some(BinaryOp::Sub),
  )
  rules.push(
    RewriteRule::new(cos_plus_special, (bindings : PatternBindings) => {
      let primary = unwrap_binding(bindings.copy(), "sum_prod_primary")
      let secondary = unwrap_binding(bindings, "sum_prod_secondary")
      mul(int(2), mul(cos(primary.copy()), cos(secondary.copy())))
    }),
  )
  rules.push(
    RewriteRule::new(cos_plus_special_swapped, (bindings : PatternBindings) => {
      let primary = unwrap_binding(bindings.copy(), "sum_prod_primary")
      let secondary = unwrap_binding(bindings, "sum_prod_secondary")
      mul(int(2), mul(cos(primary.copy()), cos(secondary.copy())))
    }),
  )
  rules.push(
    RewriteRule::new(cos_minus_special, (bindings : PatternBindings) => {
      let primary = unwrap_binding(bindings.copy(), "sum_prod_primary")
      let secondary = unwrap_binding(bindings, "sum_prod_secondary")
      mul(int(-2), mul(sin(primary.copy()), sin(secondary.copy())))
    }),
  )
  rules.push(
    RewriteRule::new(cos_minus_special_swapped, (bindings : PatternBindings) => {
      let primary = unwrap_binding(bindings.copy(), "sum_prod_primary")
      let secondary = unwrap_binding(bindings, "sum_prod_secondary")
      mul(int(2), mul(sin(primary.copy()), sin(secondary.copy())))
    }),
  )
  let cos_sum_pattern = pattern_binary(
    cos_a_cos_b.copy(),
    sin_a_sin_b.copy(),
    op=Some(BinaryOp::Sub),
  )
  rules.push(
    RewriteRule::new(cos_sum_pattern, (bindings : PatternBindings) => {
      let a = unwrap_binding(bindings.copy(), "sum_a")
      let b = unwrap_binding(bindings, "sum_b")
      cos(add(a, b))
    }),
  )
  let cos_sum_pattern_swapped = pattern_binary(
    sin_a_sin_b.copy(),
    cos_a_cos_b.copy(),
    op=Some(BinaryOp::Sub),
  )
  rules.push(
    RewriteRule::new(cos_sum_pattern_swapped, (bindings : PatternBindings) => {
      let a = unwrap_binding(bindings.copy(), "sum_a")
      let b = unwrap_binding(bindings, "sum_b")
      neg(cos(add(a, b)))
    }),
  )
  let cos_diff_pattern = pattern_binary(
    cos_a_cos_b.copy(),
    sin_a_sin_b.copy(),
    op=Some(BinaryOp::Add),
  )
  rules.push(
    RewriteRule::new(cos_diff_pattern, (bindings : PatternBindings) => {
      let a = unwrap_binding(bindings.copy(), "sum_a")
      let b = unwrap_binding(bindings, "sum_b")
      cos(sub(a, b))
    }),
  )
  let cos_diff_pattern_swapped = pattern_binary(
    sin_a_sin_b.copy(),
    cos_a_cos_b.copy(),
    op=Some(BinaryOp::Add),
  )
  rules.push(
    RewriteRule::new(cos_diff_pattern_swapped, (bindings : PatternBindings) => {
      let a = unwrap_binding(bindings.copy(), "sum_a")
      let b = unwrap_binding(bindings, "sum_b")
      cos(sub(a, b))
    }),
  )
  let dbl_theta = pattern_wildcard("dbl_theta")
  let sin_theta = pattern_unary(dbl_theta.copy(), op=Some(UnaryOp::Sin))
  let cos_theta = pattern_unary(dbl_theta.copy(), op=Some(UnaryOp::Cos))
  let sin_cos_terms : Array[Pattern] = Array::new(capacity=2)
  sin_cos_terms.push(
    pattern_binary(sin_theta.copy(), cos_theta.copy(), op=Some(BinaryOp::Mul)),
  )
  sin_cos_terms.push(
    pattern_binary(cos_theta.copy(), sin_theta.copy(), op=Some(BinaryOp::Mul)),
  )
  let sin_cos_mul = pattern_one_of(sin_cos_terms)
  let two_sin_terms : Array[Pattern] = Array::new(capacity=2)
  two_sin_terms.push(
    pattern_binary(two_literal.copy(), sin_theta.copy(), op=Some(BinaryOp::Mul)),
  )
  two_sin_terms.push(
    pattern_binary(sin_theta.copy(), two_literal.copy(), op=Some(BinaryOp::Mul)),
  )
  let two_sin_mul = pattern_one_of(two_sin_terms)
  let two_cos_terms : Array[Pattern] = Array::new(capacity=2)
  two_cos_terms.push(
    pattern_binary(two_literal.copy(), cos_theta.copy(), op=Some(BinaryOp::Mul)),
  )
  two_cos_terms.push(
    pattern_binary(cos_theta.copy(), two_literal.copy(), op=Some(BinaryOp::Mul)),
  )
  let two_cos_mul = pattern_one_of(two_cos_terms)
  let sin_sq_double = pattern_binary(
    sin_theta.copy(),
    two_literal.copy(),
    op=Some(BinaryOp::Pow),
  )
  let cos_sq_double = pattern_binary(
    cos_theta.copy(),
    two_literal.copy(),
    op=Some(BinaryOp::Pow),
  )
  let two_sin_sq_options : Array[Pattern] = Array::new(capacity=2)
  two_sin_sq_options.push(
    pattern_binary(
      two_literal.copy(),
      sin_sq_double.copy(),
      op=Some(BinaryOp::Mul),
    ),
  )
  two_sin_sq_options.push(
    pattern_binary(
      sin_sq_double.copy(),
      two_literal.copy(),
      op=Some(BinaryOp::Mul),
    ),
  )
  let two_sin_sq = pattern_one_of(two_sin_sq_options)
  let two_cos_sq_options : Array[Pattern] = Array::new(capacity=2)
  two_cos_sq_options.push(
    pattern_binary(
      two_literal.copy(),
      cos_sq_double.copy(),
      op=Some(BinaryOp::Mul),
    ),
  )
  two_cos_sq_options.push(
    pattern_binary(
      cos_sq_double.copy(),
      two_literal.copy(),
      op=Some(BinaryOp::Mul),
    ),
  )
  let two_cos_sq = pattern_one_of(two_cos_sq_options)
  let one_minus_two_sin_sq = pattern_binary(
    one_literal.copy(),
    two_sin_sq.copy(),
    op=Some(BinaryOp::Sub),
  )
  rules.push(
    RewriteRule::new(one_minus_two_sin_sq, (bindings : PatternBindings) => {
      let angle = unwrap_binding(bindings, "dbl_theta")
      cos(mul(int(2), angle))
    }),
  )
  let two_cos_sq_minus_one = pattern_binary(
    two_cos_sq.copy(),
    one_literal.copy(),
    op=Some(BinaryOp::Sub),
  )
  rules.push(
    RewriteRule::new(two_cos_sq_minus_one, (bindings : PatternBindings) => {
      let angle = unwrap_binding(bindings, "dbl_theta")
      cos(mul(int(2), angle))
    }),
  )
  let two_sin_sq_minus_one = pattern_binary(
    two_sin_sq.copy(),
    one_literal.copy(),
    op=Some(BinaryOp::Sub),
  )
  rules.push(
    RewriteRule::new(two_sin_sq_minus_one, (bindings : PatternBindings) => {
      let angle = unwrap_binding(bindings, "dbl_theta")
      neg(cos(mul(int(2), angle)))
    }),
  )
  let one_minus_two_cos_sq = pattern_binary(
    one_literal.copy(),
    two_cos_sq.copy(),
    op=Some(BinaryOp::Sub),
  )
  rules.push(
    RewriteRule::new(one_minus_two_cos_sq, (bindings : PatternBindings) => {
      let angle = unwrap_binding(bindings, "dbl_theta")
      neg(cos(mul(int(2), angle)))
    }),
  )
  let double_patterns : Array[Pattern] = {
    let candidates : Array[Pattern] = Array::new(capacity=6)
    candidates.push(
      pattern_binary(
        two_sin_mul.copy(),
        cos_theta.copy(),
        op=Some(BinaryOp::Mul),
      ),
    )
    candidates.push(
      pattern_binary(
        cos_theta.copy(),
        two_sin_mul.copy(),
        op=Some(BinaryOp::Mul),
      ),
    )
    candidates.push(
      pattern_binary(
        two_literal.copy(),
        sin_cos_mul.copy(),
        op=Some(BinaryOp::Mul),
      ),
    )
    candidates.push(
      pattern_binary(
        sin_cos_mul.copy(),
        two_literal.copy(),
        op=Some(BinaryOp::Mul),
      ),
    )
    candidates.push(
      pattern_binary(
        two_cos_mul.copy(),
        sin_theta.copy(),
        op=Some(BinaryOp::Mul),
      ),
    )
    candidates.push(
      pattern_binary(
        sin_theta.copy(),
        two_cos_mul.copy(),
        op=Some(BinaryOp::Mul),
      ),
    )
    candidates
  }
  for candidate in double_patterns {
    rules.push(
      RewriteRule::new(candidate, (bindings : PatternBindings) => {
        let angle = unwrap_binding(bindings, "dbl_theta")
        sin(mul(int(2), angle))
      }),
    )
  }
  let sin_add_same = pattern_unary(
    pattern_binary(dbl_theta.copy(), dbl_theta.copy(), op=Some(BinaryOp::Add)),
    op=Some(UnaryOp::Sin),
  )
  rules.push(
    RewriteRule::new(sin_add_same, (bindings : PatternBindings) => {
      let angle = unwrap_binding(bindings, "dbl_theta")
      sin(mul(int(2), angle))
    }),
  )
  let cos_add_same = pattern_unary(
    pattern_binary(dbl_theta.copy(), dbl_theta.copy(), op=Some(BinaryOp::Add)),
    op=Some(UnaryOp::Cos),
  )
  rules.push(
    RewriteRule::new(cos_add_same, (bindings : PatternBindings) => {
      let angle = unwrap_binding(bindings, "dbl_theta")
      cos(mul(int(2), angle))
    }),
  )
  rules
}

///|
fn apply_identity_rewrites(expr : Expr) -> Expr {
  rewrite(expr, identity_rewrite_rules())
}

///|
pub fn simplify(
  expr : Expr,
  ratio? : Double = 1.7,
  measure? : (Expr) -> Double = count_ops,
  rational? : Bool = false,
  inverse? : Bool = false,
  doit? : Bool = true,
) -> Expr {
  let preprocessed = if inverse { inverse_cancellation(expr) } else { expr }
  let simplified_once = apply_identity_rewrites(simplify_reduce(preprocessed))
  let rationalized = if rational {
    rationalize_expr(simplified_once)
  } else {
    simplified_once
  }
  let candidate = if doit {
    apply_identity_rewrites(simplify_reduce(rationalized))
  } else {
    apply_identity_rewrites(rationalized)
  }
  let original_measure = measure(expr)
  let candidate_measure = measure(candidate)
  let chosen = if should_preserve_original(
      original_measure, candidate_measure, ratio,
    ) {
    expr
  } else {
    candidate
  }
  apply_identity_rewrites(chosen)
}

///|
/// 自带评价式子复杂程度函数
pub fn count_ops(expr : Expr) -> Double {
  match expr {
    Expr::Int(_) => 0.0
    Expr::Double(_) => 0.0
    Expr::Symbol(_) => 0.0
    Expr::Unary(_, inner) => 1 + count_ops(inner)
    Expr::Binary(_, left, right) => 1 + count_ops(left) + count_ops(right)
    Expr::FunctionCall(_, args) => 1 + count_ops_args(args) // 特殊函数
  }
}

///|
/// 特殊函数情况
fn count_ops_args(args : Array[Expr]) -> Double {
  args.fold(init=0, (acc : Double, item : Expr) => acc + count_ops(item))
}

///|
/// 看看是保存之前的还是用新的替换
fn should_preserve_original(
  original : Double,
  candidate : Double,
  ratio : Double,
) -> Bool {
  if ratio <= 0.0 {
    candidate > 0.0
  } else if original == 0.0 {
    candidate > 0.0
  } else {
    let limit = original * ratio
    candidate > limit
  }
}

///|
/// 反函数消去
fn inverse_cancellation(expr : Expr) -> Expr {
  match expr {
    Expr::Unary(op, inner) => {
      let inner_simplified = inverse_cancellation(inner)
      match inner_simplified {
        Expr::Unary(inner_op, inner_arg) =>
          if unary_inverse_pair(op, inner_op) {
            inverse_cancellation(inner_arg)
          } else {
            Expr::Unary(op, Expr::Unary(inner_op, inner_arg))
          }
        other => Expr::Unary(op, other)
      }
    }
    Expr::Binary(op, left, right) =>
      Expr::Binary(op, inverse_cancellation(left), inverse_cancellation(right))
    Expr::FunctionCall(name, args) => {
      let transformed = args.map(arg => inverse_cancellation(arg))
      Expr::FunctionCall(name, transformed)
    }
    other => other
  }
}

///|
/// 实现结构有理化。
pub fn rationalize_expr(
  expr : Expr,
  constants? : Array[RationalConstant] = default_rational_constants(),
  tolerance? : Double = 1.0e-10,
  full? : Bool = false,
  rational? : Bool = true,
  rational_conversion? : String = "base10",
) -> Expr {
  if !rational {
    return expr
  }
  match expr {
    Expr::Double(value) =>
      match
        rationalize_double_value(
          value, constants, tolerance, full, rational_conversion,
        ) {
        Some(expr) => expr
        None => Expr::Double(value)
      }
    Expr::Unary(op, inner) =>
      Expr::Unary(
        op,
        rationalize_expr(
          inner,
          constants~,
          tolerance~,
          full~,
          rational~,
          rational_conversion~,
        ),
      )
    Expr::Binary(op, left, right) =>
      Expr::Binary(
        op,
        rationalize_expr(
          left,
          constants~,
          tolerance~,
          full~,
          rational~,
          rational_conversion~,
        ),
        rationalize_expr(
          right,
          constants~,
          tolerance~,
          full~,
          rational~,
          rational_conversion~,
        ),
      )
    Expr::FunctionCall(name, args) => {
      let transformed = args.map(arg => rationalize_expr(
        arg,
        constants~,
        tolerance~,
        full~,
        rational~,
        rational_conversion~,
      ))
      Expr::FunctionCall(name, transformed)
    }
    other => other
  }
}

///|
fn simplify_reduce(expr : Expr) -> Expr {
  match expr {
    Expr::Unary(UnaryOp::Neg, inner) => {
      let simplified_inner = simplify_reduce(inner)
      match simplified_inner {
        Expr::Int(value) => Expr::Int(-value)
        Expr::Double(value) => Expr::Double(-value)
        other => Expr::Unary(UnaryOp::Neg, other)
      }
    }
    Expr::Unary(op, inner) => Expr::Unary(op, simplify_reduce(inner))
    Expr::Binary(BinaryOp::Add, left, right) => simplify_add(left, right)
    Expr::Binary(BinaryOp::Sub, left, right) => simplify_sub(left, right)
    Expr::Binary(BinaryOp::Mul, left, right) => simplify_mul(left, right)
    Expr::Binary(BinaryOp::Div, left, right) => simplify_div(left, right)
    Expr::Binary(BinaryOp::Pow, base, exponent) => simplify_pow(base, exponent)
    Expr::FunctionCall(name, args) => {
      let simplified_args = args.map(arg => simplify_reduce(arg))
      Expr::FunctionCall(name, simplified_args)
    }
    other => other
  }
}

///|
/// 针对于加法处理（合并同类项）
fn simplify_add(left : Expr, right : Expr) -> Expr {
  let left_s = simplify_reduce(left)
  let right_s = simplify_reduce(right)
  let (left_zero, left_clean) = simplify_is_zero_literal(left_s)
  let (right_zero, right_clean) = simplify_is_zero_literal(right_s)
  if left_zero {
    right_clean
  } else if right_zero {
    left_clean
  } else {
    let mut terms = Array::new()
    terms = append_add_terms(left_clean, terms) // 拍平所有加法
    terms = append_add_terms(right_clean, terms)
    combine_polynomial_terms(terms)
  }
}

///|
/// 一串加法拍平，拆出所有的加法
fn append_add_terms(expr : Expr, terms : Array[Expr]) -> Array[Expr] {
  match expr {
    Expr::Binary(BinaryOp::Add, left, right) => {
      let collected = append_add_terms(left, terms)
      append_add_terms(right, collected)
    }
    other => {
      let updated = terms
      updated.push(other)
      updated
    }
  }
}

///|
fn combine_polynomial_terms(terms : Array[Expr]) -> Expr {
  let monomials = Array::new()
  let coefficients = Array::new()
  for term in terms {
    let (coeff, factors) = extract_polynomial_term(term) // 分解为系数+因子
    let normalized_factors = normalize_factors(factors)
    let monomial = build_monomial_from_factors(normalized_factors)
    let index = find_monomial_index(monomials, monomial)
    if index < 0 {
      monomials.push(monomial)
      coefficients.push(coeff)
    } else {
      let existing = coefficients[index]
      coefficients[index] = add_coefficients(existing, coeff)
    }
  }
  let mut result : Expr? = None
  let len = monomials.length()
  for i in 0..<len {
    let coeff = coefficients[i]
    let monomial = monomials[i]
    if is_zero_coefficient(coeff) {
      continue
    }
    let term_expr = term_from_parts(coeff, monomial)
    let (is_zero_term, _) = simplify_is_zero_literal(term_expr)
    if is_zero_term {
      continue
    }
    match result {
      Some(current) =>
        result = Some(Expr::Binary(BinaryOp::Add, current, term_expr))
      None => result = Some(term_expr)
    }
  }
  match result {
    Some(expr) => expr
    None => Expr::Int(0)
  }
}

///|
/// 输入表达式输出系数和因子数组，以供合并同类项
fn extract_polynomial_term(expr : Expr) -> (Expr, Array[Expr]) {
  match expr {
    Expr::Binary(BinaryOp::Mul, left, right) => {
      let (left_coeff, left_factors) = extract_polynomial_term(left)
      let (right_coeff, right_factors) = extract_polynomial_term(right)
      let combined_coeff = multiply_coefficients(left_coeff, right_coeff)
      let merged_factors = merge_factors(left_factors, right_factors)
      (combined_coeff, merged_factors)
    }
    Expr::Unary(UnaryOp::Neg, inner) => {
      let (inner_coeff, inner_factors) = extract_polynomial_term(inner)
      let negated_coeff = multiply_coefficients(Expr::Int(-1), inner_coeff)
      (negated_coeff, inner_factors)
    }
    Expr::Int(value) => {
      let factors = Array::new()
      (Expr::Int(value), factors)
    }
    Expr::Double(value) => {
      let factors = Array::new()
      (Expr::Double(value), factors)
    }
    other => {
      let factors = Array::new(capacity=1)
      factors.push(other)
      (Expr::Int(1), factors)
    }
  }
}

///|
/// 合并拆解因子列表函数
fn merge_factors(left : Array[Expr], right : Array[Expr]) -> Array[Expr] {
  let merged = Array::new(capacity=left.length() + right.length())
  for item in left {
    merged.push(item)
  }
  for item in right {
    merged.push(item)
  }
  merged
}

///|
/// 让传入的因子顺序均相同，使用冒泡排序
fn normalize_factors(factors : Array[Expr]) -> Array[Expr] {
  let normalized = Array::new(capacity=factors.length())
  for factor in factors {
    normalized.push(factor)
  }
  let len = normalized.length()
  for i = 0; i < len; i = i + 1 {
    for j = i + 1; j < len; j = j + 1 {
      let sig_i = normalized[i].to_string()
      let sig_j = normalized[j].to_string()
      if sig_j < sig_i {
        let temp_expr = normalized[i]
        normalized[i] = normalized[j]
        normalized[j] = temp_expr
      }
    }
  }
  normalized
}

///|
/// 将拆开的系数乘法合并出来
fn build_monomial_from_factors(factors : Array[Expr]) -> Expr {
  let len = factors.length()
  if len == 0 {
    Expr::Int(1)
  } else if len == 1 {
    factors[0]
  } else {
    let mut result = factors[0]
    for i in 1..<len {
      result = Expr::Binary(BinaryOp::Mul, result, factors[i])
    }
    result
  }
}

///|
/// 查找并返回目标单项式的位置
fn find_monomial_index(monomials : Array[Expr], target : Expr) -> Int {
  let len = monomials.length()
  for i in 0..<len {
    if monomials[i] == target {
      return i
    }
  }
  -1
}

///|
/// 系数加法穷举
fn add_coefficients(lhs : Expr, rhs : Expr) -> Expr {
  match (lhs, rhs) {
    (Expr::Int(left_val), Expr::Int(right_val)) =>
      Expr::Int(left_val + right_val)
    (Expr::Double(left_val), Expr::Double(right_val)) =>
      Expr::Double(left_val + right_val)
    (Expr::Int(left_val), Expr::Double(right_val)) =>
      Expr::Double(left_val.to_double() + right_val)
    (Expr::Double(left_val), Expr::Int(right_val)) =>
      Expr::Double(left_val + right_val.to_double())
    (Expr::Int(0), other) => other
    (other, Expr::Int(0)) => other
    (Expr::Double(0.0), other) => other
    (other, Expr::Double(0.0)) => other
    (left_expr, right_expr) =>
      Expr::Binary(BinaryOp::Add, left_expr, right_expr)
  }
}

///|
/// 系数乘法穷举
fn multiply_coefficients(lhs : Expr, rhs : Expr) -> Expr {
  match (lhs, rhs) {
    (Expr::Int(left_val), Expr::Int(right_val)) =>
      Expr::Int(left_val * right_val)
    (Expr::Double(left_val), Expr::Double(right_val)) =>
      Expr::Double(left_val * right_val)
    (Expr::Int(left_val), Expr::Double(right_val)) =>
      Expr::Double(left_val.to_double() * right_val)
    (Expr::Double(left_val), Expr::Int(right_val)) =>
      Expr::Double(left_val * right_val.to_double())
    (Expr::Int(1), other) => other
    (other, Expr::Int(1)) => other
    (Expr::Double(1.0), other) => other
    (other, Expr::Double(1.0)) => other
    (left_expr, right_expr) =>
      Expr::Binary(BinaryOp::Mul, left_expr, right_expr)
  }
}

///|
fn term_from_parts(coeff : Expr, monomial : Expr) -> Expr {
  let (coeff_zero, coeff_clean) = simplify_is_zero_literal(coeff)
  if coeff_zero {
    return Expr::Int(0)
  }
  let (coeff_one, coeff_value) = simplify_is_one_literal(coeff_clean)
  if monomial == Expr::Int(1) {
    coeff_value
  } else if coeff_one {
    monomial
  } else if simplify_is_minus_one_literal(coeff_value) {
    Expr::Unary(UnaryOp::Neg, monomial)
  } else {
    Expr::Binary(BinaryOp::Mul, coeff_value, monomial)
  }
}

///|
fn is_zero_coefficient(expr : Expr) -> Bool {
  let (is_zero, _) = simplify_is_zero_literal(expr)
  is_zero
}

///|
fn simplify_is_minus_one_literal(expr : Expr) -> Bool {
  match expr {
    Expr::Int(value) => value == -1
    Expr::Double(value) => value == -1.0
    _ => false
  }
}

///|
/// sympy中不使用这个sub方法，a-b转化成a+(-1)*b
fn simplify_sub(left : Expr, right : Expr) -> Expr {
  let left_s = simplify_reduce(left)
  let right_s = simplify_reduce(right)
  let (right_zero, right_clean) = simplify_is_zero_literal(right_s)
  if right_zero {
    left_s
  } else {
    match (left_s, right_clean) {
      (Expr::Int(lhs), Expr::Int(rhs)) => Expr::Int(lhs - rhs)
      (Expr::Double(lhs), Expr::Double(rhs)) => Expr::Double(lhs - rhs)
      (lhs, rhs) => Expr::Binary(BinaryOp::Sub, lhs, rhs)
    }
  }
}

///|
/// 针对乘法处理（合并系数，合并幂）
fn simplify_mul(left : Expr, right : Expr) -> Expr {
  let left_s = simplify_reduce(left)
  let right_s = simplify_reduce(right)
  let (left_zero, left_clean) = simplify_is_zero_literal(left_s)
  let (right_zero, right_clean) = simplify_is_zero_literal(right_s)
  if left_zero || right_zero {
    return Expr::Int(0)
  }
  let mut factors = Array::new()
  factors = collect_mul_factors(left_clean, factors)
  factors = collect_mul_factors(right_clean, factors)
  let mut coeff_int = 1
  let mut has_int = false
  let mut coeff_double : Double? = None
  let mut symbol_counts : Array[(Expr, Int)] = Array::new()
  let other_factors : Array[Expr] = Array::new()
  let denominator_factors : Array[Expr] = Array::new()
  let mut is_negative = false
  for factor in factors {
    match factor {
      Expr::Int(value) => {
        if value == 0 {
          return Expr::Int(0)
        }
        coeff_int = coeff_int * value
        has_int = true
      }
      Expr::Double(value) => {
        if value == 0.0 {
          return Expr::Double(0.0)
        }
        coeff_double = match coeff_double {
          Some(current) => Some(current * value)
          None => Some(value)
        }
      }
      Expr::Binary(BinaryOp::Pow, Expr::Symbol(symbol), Expr::Int(exp)) => {
        let base = Expr::Symbol(symbol)
        symbol_counts = add_symbol_power(symbol_counts, base, exp)
      }
      Expr::Symbol(symbol) => {
        let base = Expr::Symbol(symbol)
        symbol_counts = add_symbol_power(symbol_counts, base, 1)
      }
      Expr::Binary(BinaryOp::Div, Expr::Int(1), denominator) =>
        denominator_factors.push(simplify_reduce(denominator))
      Expr::Binary(BinaryOp::Div, Expr::Int(-1), denominator) => {
        is_negative = !is_negative
        denominator_factors.push(simplify_reduce(denominator))
      }
      other => other_factors.push(other)
    }
  }
  if has_int && coeff_int == 0 {
    return Expr::Int(0)
  }
  let final_factors = Array::new()
  match coeff_double {
    Some(value) => {
      let combined = if has_int { value * coeff_int.to_double() } else { value }
      if combined == 0.0 {
        return Expr::Double(0.0)
      }
      let magnitude = if combined < 0.0 {
        is_negative = !is_negative
        -combined
      } else {
        combined
      }
      if magnitude != 1.0 {
        final_factors.push(Expr::Double(magnitude))
      }
      has_int = false
      coeff_int = 1
    }
    None => ()
  }
  if has_int {
    let magnitude = if coeff_int < 0 {
      is_negative = !is_negative
      -coeff_int
    } else {
      coeff_int
    }
    if magnitude != 1 {
      final_factors.push(Expr::Int(magnitude))
    }
  }
  for entry in symbol_counts {
    let (base, power) = entry
    if power == 0 {
      continue
    }
    if power == 1 {
      final_factors.push(base)
    } else {
      final_factors.push(Expr::Binary(BinaryOp::Pow, base, Expr::Int(power)))
    }
  }
  for factor in other_factors {
    final_factors.push(factor)
  }
  let len = final_factors.length()
  let base_expr = if len == 0 {
    Expr::Int(1)
  } else if len == 1 {
    final_factors[0]
  } else {
    build_monomial_from_factors(final_factors)
  }
  let signed_expr = if is_negative {
    match base_expr {
      Expr::Int(value) => Expr::Int(-value)
      Expr::Double(value) => Expr::Double(-value)
      Expr::Unary(UnaryOp::Neg, inner) => inner
      Expr::Binary(BinaryOp::Mul, Expr::Int(-1), rest) => rest
      Expr::Binary(BinaryOp::Mul, rest, Expr::Int(-1)) => rest
      other => Expr::Unary(UnaryOp::Neg, other)
    }
  } else {
    base_expr
  }
  if denominator_factors.length() == 0 {
    signed_expr
  } else {
    let denom_expr = if denominator_factors.length() == 1 {
      denominator_factors[0]
    } else {
      build_monomial_from_factors(denominator_factors)
    }
    simplify_div(signed_expr, denom_expr)
  }
}

///|
/// 收集乘法因子
fn collect_mul_factors(expr : Expr, factors : Array[Expr]) -> Array[Expr] {
  match expr {
    Expr::Binary(BinaryOp::Mul, left, right) => {
      let collected = collect_mul_factors(left, factors)
      collect_mul_factors(right, collected)
    }
    Expr::Binary(BinaryOp::Div, numerator, denominator) => {
      let collected = collect_mul_factors(numerator, factors)
      collect_divisor_factors(denominator, collected)
    }
    Expr::Unary(UnaryOp::Neg, inner) => {
      let updated = factors
      updated.push(Expr::Int(-1))
      collect_mul_factors(inner, updated)
    }
    other => {
      let updated = factors
      updated.push(other)
      updated
    }
  }
}

///|
fn collect_divisor_factors(expr : Expr, factors : Array[Expr]) -> Array[Expr] {
  match expr {
    Expr::Binary(BinaryOp::Mul, left, right) => {
      let collected = collect_divisor_factors(left, factors)
      collect_divisor_factors(right, collected)
    }
    Expr::Binary(BinaryOp::Div, numerator, denominator) => {
      let collected = collect_divisor_factors(numerator, factors)
      collect_divisor_factors(denominator, collected)
    }
    Expr::Unary(UnaryOp::Neg, inner) => {
      let updated = factors
      updated.push(Expr::Int(-1))
      collect_divisor_factors(inner, updated)
    }
    Expr::Binary(BinaryOp::Pow, Expr::Symbol(symbol), Expr::Int(exp)) => {
      let base = Expr::Symbol(symbol)
      let updated = factors
      updated.push(Expr::Binary(BinaryOp::Pow, base, Expr::Int(-exp)))
      updated
    }
    Expr::Binary(BinaryOp::Pow, base, Expr::Int(exp)) => {
      let updated = factors
      updated.push(Expr::Binary(BinaryOp::Pow, base, Expr::Int(-exp)))
      updated
    }
    Expr::Symbol(_) => {
      let updated = factors
      updated.push(Expr::Binary(BinaryOp::Pow, expr, Expr::Int(-1)))
      updated
    }
    Expr::Int(value) =>
      if value == 0 {
        let updated = factors
        updated.push(Expr::Binary(BinaryOp::Div, Expr::Int(1), Expr::Int(0)))
        updated
      } else {
        let updated = factors
        updated.push(
          Expr::Binary(BinaryOp::Div, Expr::Int(1), Expr::Int(value)),
        )
        updated
      }
    Expr::Double(value) =>
      if value == 0.0 {
        let updated = factors
        updated.push(
          Expr::Binary(BinaryOp::Div, Expr::Int(1), Expr::Double(0.0)),
        )
        updated
      } else {
        let updated = factors
        updated.push(Expr::Double(1.0 / value))
        updated
      }
    other => {
      let updated = factors
      updated.push(Expr::Binary(BinaryOp::Div, Expr::Int(1), other))
      updated
    }
  }
}

///|
fn pow_product_with_int(
  coeff : Expr,
  factors : Array[Expr],
  exponent : Int,
) -> Expr {
  if exponent == 0 {
    return Expr::Int(1)
  }
  let coeff_pow = simplify_pow(coeff, Expr::Int(exponent))
  let len = factors.length()
  let mut result = coeff_pow
  for i in 0..<len {
    let factor_pow = simplify_pow(factors[i], Expr::Int(exponent))
    result = simplify_mul(result, factor_pow)
  }
  result
}

///|
fn pow_product_with_double(
  coeff : Expr,
  factors : Array[Expr],
  exponent_expr : Expr,
  exponent_value : Double,
) -> Expr {
  if exponent_value == 0.0 {
    return Expr::Int(1)
  }
  let coeff_value = match coeff {
    Expr::Int(v) => v.to_double()
    Expr::Double(v) => v
    _ => 1.0
  }
  let coeff_pow = @math.pow(coeff_value, exponent_value)
  let coeff_expr = if is_integral_double(coeff_pow) {
    Expr::Int(@math.round(coeff_pow).to_int())
  } else {
    Expr::Double(coeff_pow)
  }
  let len = factors.length()
  let mut result = coeff_expr
  for i in 0..<len {
    let factor_pow = simplify_pow(factors[i], exponent_expr)
    result = simplify_mul(result, factor_pow)
  }
  result
}

///|
fn abs_double(value : Double) -> Double {
  if value < 0.0 {
    -value
  } else {
    value
  }
}

///|
fn is_integral_double(value : Double) -> Bool {
  let rounded = @math.round(value)
  abs_double(value - rounded) <= 1.0e-10
}

///|
/// 合并相同符号的幂
fn add_symbol_power(
  symbol_counts : Array[(Expr, Int)],
  base : Expr,
  delta : Int,
) -> Array[(Expr, Int)] {
  let len = symbol_counts.length()
  for i in 0..<len {
    let (existing_base, existing_power) = symbol_counts[i]
    if existing_base == base {
      symbol_counts[i] = (existing_base, existing_power + delta)
      return symbol_counts
    } else {
      symbol_counts[i] = (existing_base, existing_power)
    }
  }
  symbol_counts.push((base, delta))
  symbol_counts
}

///|
fn int_pow(base : Int, exponent : Int) -> Int {
  if exponent <= 0 {
    return 1
  }
  let mut result = 1
  let mut e = exponent
  let mut b = base
  while e > 0 {
    if e % 2 != 0 {
      result = result * b
    }
    e = e / 2
    if e > 0 {
      b = b * b
    }
  }
  result
}

///|
fn simplify_div(left : Expr, right : Expr) -> Expr {
  let left_s = simplify_reduce(left)
  let right_s = simplify_reduce(right)
  let (right_one, right_clean) = simplify_is_one_literal(right_s)
  if right_one {
    left_s
  } else {
    match (left_s, right_clean) {
      (Expr::Int(lhs), Expr::Int(rhs)) =>
        if rhs != 0 && lhs % rhs == 0 {
          Expr::Int(lhs / rhs)
        } else {
          Expr::Binary(BinaryOp::Div, Expr::Int(lhs), Expr::Int(rhs))
        }
      (Expr::Double(lhs), Expr::Double(rhs)) => Expr::Double(lhs / rhs)
      (lhs, rhs) => Expr::Binary(BinaryOp::Div, lhs, rhs)
    }
  }
}

///|
fn simplify_pow(base : Expr, exponent : Expr) -> Expr {
  let base_s = simplify_reduce(base)
  let exponent_s = simplify_reduce(exponent)
  let (exp_zero, exp_clean) = simplify_is_zero_literal(exponent_s)
  if exp_zero {
    return Expr::Int(1)
  }
  let (exp_one, exp_value) = simplify_is_one_literal(exp_clean)
  if exp_one {
    return base_s
  }
  let exp_int = match exp_value {
    Expr::Int(value) => Some(value)
    _ => None
  }
  match base_s {
    Expr::Int(value) =>
      match exp_int {
        Some(exp_val) =>
          if exp_val >= 0 {
            if value == 0 {
              return Expr::Int(0)
            }
            if value == 1 {
              return Expr::Int(1)
            }
            if value == -1 {
              if exp_val % 2 == 0 {
                return Expr::Int(1)
              } else {
                return Expr::Int(-1)
              }
            }
            return Expr::Int(int_pow(value, exp_val))
          } else {
            let abs_exp = -exp_val
            if value == 0 {
              return Expr::Binary(BinaryOp::Pow, Expr::Int(0), exp_value)
            }
            if value == 1 {
              return Expr::Int(1)
            }
            if value == -1 {
              if abs_exp % 2 == 0 {
                return Expr::Int(1)
              } else {
                return Expr::Int(-1)
              }
            }
            let positive = simplify_pow(Expr::Int(value), Expr::Int(abs_exp))
            return simplify_div(Expr::Int(1), positive)
          }
        None => {
          if value == 0 {
            return Expr::Int(0)
          }
          if value == 1 {
            return Expr::Int(1)
          }
          if value == -1 {
            return Expr::Binary(BinaryOp::Pow, base_s, exp_value)
          }
        }
      }
    Expr::Double(value) =>
      match exp_int {
        Some(exp_val) => {
          if value == 0.0 {
            if exp_val < 0 {
              return Expr::Binary(BinaryOp::Pow, base_s, exp_value)
            } else {
              return Expr::Double(0.0)
            }
          }
          if value == 1.0 {
            return Expr::Double(1.0)
          }
          if value == -1.0 {
            if exp_val % 2 == 0 {
              return Expr::Double(1.0)
            } else {
              return Expr::Double(-1.0)
            }
          }
          let combined = @math.pow(value, exp_val.to_double())
          return Expr::Double(combined)
        }
        None =>
          match exp_value {
            Expr::Double(exp_double) => {
              if value == 0.0 && exp_double < 0.0 {
                return Expr::Binary(BinaryOp::Pow, base_s, exp_value)
              }
              if value == 1.0 {
                return Expr::Double(1.0)
              }
              if value == -1.0 {
                return Expr::Binary(BinaryOp::Pow, base_s, exp_value)
              }
              let combined = @math.pow(value, exp_double)
              return Expr::Double(combined)
            }
            _ => {
              if value == 0.0 {
                return Expr::Double(0.0)
              }
              if value == 1.0 {
                return Expr::Double(1.0)
              }
              if value == -1.0 {
                return Expr::Binary(BinaryOp::Pow, base_s, exp_value)
              }
            }
          }
      }
    Expr::Binary(BinaryOp::Mul, _, _) =>
      match exp_int {
        Some(exp_val) => {
          let (coeff, factors) = extract_polynomial_term(base_s)
          match coeff {
            Expr::Int(_) | Expr::Double(_) => {
              let abs_exp = if exp_val < 0 { -exp_val } else { exp_val }
              let positive = pow_product_with_int(coeff, factors, abs_exp)
              if exp_val >= 0 {
                return positive
              } else {
                return simplify_div(Expr::Int(1), positive)
              }
            }
            _ => ()
          }
        }
        None =>
          match exp_value {
            Expr::Double(exp_double) => {
              let (coeff, factors) = extract_polynomial_term(base_s)
              match coeff {
                Expr::Int(coeff_int) =>
                  if coeff_int < 0 && !is_integral_double(exp_double) {
                    ()
                  } else {
                    let positive_exp = if exp_double < 0.0 {
                      -exp_double
                    } else {
                      exp_double
                    }
                    let exponent_expr = Expr::Double(positive_exp)
                    let positive = pow_product_with_double(
                      Expr::Int(coeff_int),
                      factors,
                      exponent_expr,
                      positive_exp,
                    )
                    if exp_double >= 0.0 {
                      return positive
                    } else {
                      return simplify_div(Expr::Int(1), positive)
                    }
                  }
                Expr::Double(coeff_double) =>
                  if coeff_double < 0.0 && !is_integral_double(exp_double) {
                    ()
                  } else {
                    let positive_exp = if exp_double < 0.0 {
                      -exp_double
                    } else {
                      exp_double
                    }
                    let exponent_expr = Expr::Double(positive_exp)
                    let positive = pow_product_with_double(
                      Expr::Double(coeff_double),
                      factors,
                      exponent_expr,
                      positive_exp,
                    )
                    if exp_double >= 0.0 {
                      return positive
                    } else {
                      return simplify_div(Expr::Int(1), positive)
                    }
                  }
                _ => ()
              }
            }
            _ => ()
          }
      }
    Expr::Binary(BinaryOp::Pow, inner_base, inner_exp) => {
      match (inner_exp, exp_value) {
        (
          Expr::Int(inner_n),
          Expr::Binary(BinaryOp::Div, Expr::Int(1), Expr::Int(outer_n)),
        ) =>
          if inner_n > 0 && outer_n > 0 && inner_n == outer_n {
            if inner_n % 2 == 0 {
              return abs(inner_base)
            } else {
              return inner_base
            }
          }
        _ => ()
      }
      let combined_exp = simplify_mul(inner_exp, exp_value)
      return simplify_pow(inner_base, combined_exp)
    }
    _ => ()
  }
  match exp_int {
    Some(exp_val) =>
      if exp_val < 0 {
        let positive_exp = Expr::Int(-exp_val)
        let positive_pow = simplify_pow(base_s, positive_exp)
        simplify_div(Expr::Int(1), positive_pow)
      } else {
        Expr::Binary(BinaryOp::Pow, base_s, exp_value)
      }
    None => Expr::Binary(BinaryOp::Pow, base_s, exp_value)
  }
}

///|
fn simplify_is_zero_literal(expr : Expr) -> (Bool, Expr) {
  match expr {
    Expr::Int(value) =>
      if value == 0 {
        (true, Expr::Int(0))
      } else {
        (false, Expr::Int(value))
      }
    Expr::Double(value) =>
      if value == 0.0 {
        (true, Expr::Double(0.0))
      } else {
        (false, Expr::Double(value))
      }
    other => (false, other)
  }
}

///|
fn simplify_is_one_literal(expr : Expr) -> (Bool, Expr) {
  match expr {
    Expr::Int(value) =>
      if value == 1 {
        (true, Expr::Int(1))
      } else {
        (false, Expr::Int(value))
      }
    Expr::Double(value) =>
      if value == 1.0 {
        (true, Expr::Double(1.0))
      } else {
        (false, Expr::Double(value))
      }
    other => (false, other)
  }
}

///|
fn unary_inverse_pair(outer : UnaryOp, inner : UnaryOp) -> Bool {
  match (outer, inner) {
    (UnaryOp::Neg, UnaryOp::Neg)
    | (UnaryOp::Sin, UnaryOp::Asin)
    | (UnaryOp::Asin, UnaryOp::Sin)
    | (UnaryOp::Cos, UnaryOp::Acos)
    | (UnaryOp::Acos, UnaryOp::Cos)
    | (UnaryOp::Tan, UnaryOp::Atan)
    | (UnaryOp::Atan, UnaryOp::Tan)
    | (UnaryOp::Sinh, UnaryOp::Asinh)
    | (UnaryOp::Asinh, UnaryOp::Sinh)
    | (UnaryOp::Cosh, UnaryOp::Acosh)
    | (UnaryOp::Acosh, UnaryOp::Cosh)
    | (UnaryOp::Tanh, UnaryOp::Atanh)
    | (UnaryOp::Atanh, UnaryOp::Tanh)
    | (UnaryOp::Exp, UnaryOp::Log)
    | (UnaryOp::Log, UnaryOp::Exp) => true
    _ => false
  }
}
