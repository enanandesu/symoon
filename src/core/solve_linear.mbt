///|
pub fn solve_linear_equation(
  lhs : Expr,
  rhs : Expr,
  variable_name : String,
) -> Expr {
  let equation = simplify(sub(lhs, rhs))
  let coeff = simplify(coefficient_of(equation, variable_name))
  let constant = simplify(coefficient_of(equation, variable_name, degree=0))
  if contains_coeff_placeholder(coeff) || contains_coeff_placeholder(constant) {
    return solve_linear_fallback(variable_name, lhs, rhs)
  }
  if is_zero_literal_linear(coeff) {
    return solve_linear_fallback(variable_name, lhs, rhs)
  }
  let neg_constant = simplify(Expr::Unary(UnaryOp::Neg, constant))
  build_fraction(neg_constant, coeff)
}

///|
pub fn solve_linear_system(
  lhs1 : Expr,
  rhs1 : Expr,
  lhs2 : Expr,
  rhs2 : Expr,
  var_x : String,
  var_y : String,
) -> (Expr, Expr) {
  let eq1 = simplify(sub(lhs1, rhs1))
  let eq2 = simplify(sub(lhs2, rhs2))
  let a1 = simplify(coefficient_of(eq1, var_x))
  let b1 = simplify(coefficient_of(eq1, var_y))
  let c1 = constant_term(eq1, var_x, var_y)
  let a2 = simplify(coefficient_of(eq2, var_x))
  let b2 = simplify(coefficient_of(eq2, var_y))
  let c2 = constant_term(eq2, var_x, var_y)
  if coefficients_need_fallback([a1, b1, c1, a2, b2, c2]) {
    return solve_linear_system_fallback(lhs1, rhs1, lhs2, rhs2, var_x, var_y)
  }
  let det = simplify(
    sub(
      Expr::Binary(BinaryOp::Mul, a1, b2),
      Expr::Binary(BinaryOp::Mul, a2, b1),
    ),
  )
  if is_zero_literal_linear(det) {
    return solve_linear_system_fallback(lhs1, rhs1, lhs2, rhs2, var_x, var_y)
  }
  let rhs_vec1 = simplify(Expr::Unary(UnaryOp::Neg, c1))
  let rhs_vec2 = simplify(Expr::Unary(UnaryOp::Neg, c2))
  let numerator_x = simplify(
    sub(
      Expr::Binary(BinaryOp::Mul, rhs_vec1, b2),
      Expr::Binary(BinaryOp::Mul, b1, rhs_vec2),
    ),
  )
  let numerator_y = simplify(
    sub(
      Expr::Binary(BinaryOp::Mul, a1, rhs_vec2),
      Expr::Binary(BinaryOp::Mul, rhs_vec1, a2),
    ),
  )
  let x_solution = build_fraction(numerator_x, det)
  let y_solution = build_fraction(numerator_y, det)
  (x_solution, y_solution)
}

///|
fn coefficients_need_fallback(values : Array[Expr]) -> Bool {
  for value in values {
    if contains_coeff_placeholder(value) {
      return true
    }
  }
  false
}

///|
fn contains_coeff_placeholder(expr : Expr) -> Bool {
  match expr {
    Expr::FunctionCall(name, args) =>
      if name == "coeff" {
        true
      } else {
        for arg in args {
          if contains_coeff_placeholder(arg) {
            return true
          }
        }
        false
      }
    Expr::Unary(_, inner) => contains_coeff_placeholder(inner)
    Expr::Binary(_, left, right) =>
      contains_coeff_placeholder(left) || contains_coeff_placeholder(right)
    _ => false
  }
}

///|
fn constant_term(expr : Expr, var_x : String, var_y : String) -> Expr {
  let without_x = substitute_variable_linear(expr, var_x, Expr::Int(0))
  let without_y = substitute_variable_linear(without_x, var_y, Expr::Int(0))
  simplify(without_y)
}

///|
fn substitute_variable_linear(
  expr : Expr,
  variable_name : String,
  replacement : Expr,
) -> Expr {
  match expr {
    Expr::Int(_) => expr
    Expr::Double(_) => expr
    Expr::Symbol(symbol) =>
      if symbol.name == variable_name {
        replacement.copy()
      } else {
        expr
      }
    Expr::Unary(op, inner) => {
      let substituted = substitute_variable_linear(
        inner, variable_name, replacement,
      )
      Expr::Unary(op, substituted)
    }
    Expr::Binary(op, left, right) => {
      let new_left = substitute_variable_linear(
        left, variable_name, replacement,
      )
      let new_right = substitute_variable_linear(
        right, variable_name, replacement,
      )
      Expr::Binary(op, new_left, new_right)
    }
    Expr::FunctionCall(name, args) => {
      let new_args = Array::new(capacity=args.length())
      for arg in args {
        new_args.push(
          substitute_variable_linear(arg, variable_name, replacement),
        )
      }
      Expr::FunctionCall(name, new_args)
    }
  }
}

///|
fn solve_linear_fallback(
  variable_name : String,
  lhs : Expr,
  rhs : Expr,
) -> Expr {
  let args = Array::new()
  args.push(sym(variable_name))
  args.push(lhs)
  args.push(rhs)
  Expr::FunctionCall("solve_linear".to_string(), args)
}

///|
fn solve_linear_system_fallback(
  lhs1 : Expr,
  rhs1 : Expr,
  lhs2 : Expr,
  rhs2 : Expr,
  var_x : String,
  var_y : String,
) -> (Expr, Expr) {
  let args = Array::new()
  args.push(sym(var_x))
  args.push(sym(var_y))
  args.push(lhs1)
  args.push(rhs1)
  args.push(lhs2)
  args.push(rhs2)
  let fallback = Expr::FunctionCall("solve_linear_system".to_string(), args)
  (fallback.copy(), fallback)
}

///|
fn build_fraction(numerator : Expr, denominator : Expr) -> Expr {
  match denominator {
    Expr::Int(value) =>
      if value < 0 {
        let new_num = simplify(negate_expr(numerator))
        let new_den = Expr::Int(-value)
        return simplify(Expr::Binary(BinaryOp::Div, new_num, new_den))
      }
    Expr::Double(value) =>
      if value < 0.0 {
        let new_num = simplify(negate_expr(numerator))
        let new_den = Expr::Double(-value)
        return simplify(Expr::Binary(BinaryOp::Div, new_num, new_den))
      }
    Expr::Unary(UnaryOp::Neg, inner) => {
      let new_num = simplify(negate_expr(numerator))
      return build_fraction(new_num, inner)
    }
    _ => ()
  }
  simplify(Expr::Binary(BinaryOp::Div, numerator, denominator))
}

///|
fn negate_expr(expr : Expr) -> Expr {
  match expr {
    Expr::Unary(UnaryOp::Neg, inner) => inner
    _ => Expr::Unary(UnaryOp::Neg, expr)
  }
}

///|
fn is_zero_literal_linear(expr : Expr) -> Bool {
  match expr {
    Expr::Int(value) => value == 0
    Expr::Double(value) => value == 0.0
    Expr::Unary(UnaryOp::Neg, inner) => is_zero_literal(inner)
    _ => false
  }
}
