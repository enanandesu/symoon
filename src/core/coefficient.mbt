///|
pub fn coefficient_of(
  expr : Expr,
  variable_name : String,
  degree? : Int = 1,
) -> Expr {
  if degree < 0 {
    abort("degree must be non-negative")
  }
  let simplified = simplify(expr)
  if degree == 0 {
    return simplify(
      substitute_variable(simplified, variable_name, Expr::Int(0)),
    )
  }
  if !expr_contains_variable(simplified, variable_name) {
    return Expr::Int(0)
  }
  if contains_diff_fallback(simplified) {
    return coefficient_fallback(variable_name, degree, simplified)
  }
  let derivative = simplify(
    differentiate(simplified, variable_name, order=degree),
  )
  if contains_diff_fallback(derivative) {
    return coefficient_fallback(variable_name, degree, derivative)
  }
  if is_zero_literal(derivative) {
    return Expr::Int(0)
  }
  let evaluated = simplify(
    substitute_variable(derivative, variable_name, Expr::Int(0)),
  )
  let factorial_value = factorial_int(degree)
  divide_by_factorial(evaluated, factorial_value)
}

///|
fn substitute_variable(
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
      let substituted = substitute_variable(inner, variable_name, replacement)
      Expr::Unary(op, substituted)
    }
    Expr::Binary(op, left, right) => {
      let new_left = substitute_variable(left, variable_name, replacement)
      let new_right = substitute_variable(right, variable_name, replacement)
      Expr::Binary(op, new_left, new_right)
    }
    Expr::FunctionCall(name, args) => {
      let new_args = Array::new(capacity=args.length())
      for arg in args {
        new_args.push(substitute_variable(arg, variable_name, replacement))
      }
      Expr::FunctionCall(name, new_args)
    }
  }
}

///|
fn coefficient_fallback(
  variable_name : String,
  degree : Int,
  expr : Expr,
) -> Expr {
  let args = Array::new()
  args.push(sym(variable_name))
  args.push(Expr::Int(degree))
  args.push(normalize_negation(expr))
  Expr::FunctionCall("coeff".to_string(), args)
}
