///|
pub fn leading_coefficient(expr : Expr, variable_name : String) -> Expr {
  let simplified = simplify(expr)
  if contains_diff_fallback(simplified) {
    return leading_coeff_fallback(variable_name, simplified)
  }
  if !expr_contains_variable(simplified, variable_name) ||
    is_zero_literal(simplified) {
    return simplified
  }
  let max_iterations = 64
  let degree = 0
  leading_coeff_iter(simplified, variable_name, degree, max_iterations)
}

///|
fn leading_coeff_iter(
  current : Expr,
  variable_name : String,
  degree : Int,
  max_iterations : Int,
) -> Expr {
  if degree >= max_iterations {
    return leading_coeff_fallback(variable_name, current)
  }
  let derivative = simplify(differentiate(current, variable_name))
  if contains_diff_fallback(derivative) {
    return leading_coeff_fallback(variable_name, derivative)
  }
  if is_zero_literal(derivative) {
    let factorial_value = factorial_int(degree)
    return divide_by_factorial(current, factorial_value)
  }
  leading_coeff_iter(derivative, variable_name, degree + 1, max_iterations)
}

///|
fn factorial_int(value : Int) -> Int {
  if value <= 1 {
    1
  } else {
    let mut result = 1
    for i in 2..=value {
      result = result * i
    }
    result
  }
}

///|
fn divide_by_factorial(expr : Expr, factorial_value : Int) -> Expr {
  if factorial_value <= 1 {
    return expr
  }
  match expr {
    Constant(ConstantLiteral::Integer(value)) =>
      if value % factorial_value == 0 {
        int(value / factorial_value)
      } else {
        let numerator = value.to_double()
        let denominator = factorial_value.to_double()
        double(numerator / denominator)
      }
    Constant(ConstantLiteral::Float(value)) => {
      let denominator = factorial_value.to_double()
      double(value / denominator)
    }
    _ => {
      let denominator_expr = int(factorial_value)
      simplify(Binary(Div, expr, denominator_expr))
    }
  }
}

///|
fn is_zero_literal(expr : Expr) -> Bool {
  match expr {
    Constant(ConstantLiteral::Integer(value)) => value == 0
    Constant(ConstantLiteral::Float(value)) => value == 0.0
    Unary(Neg, inner) => is_zero_literal(inner)
    _ => false
  }
}

///|
fn expr_contains_variable(expr : Expr, variable_name : String) -> Bool {
  match expr {
    Constant(_) => false
    Symbol(symbol) => symbol.name == variable_name
    Unary(_, inner) => expr_contains_variable(inner, variable_name)
    Binary(_, left, right) =>
      expr_contains_variable(left, variable_name) ||
      expr_contains_variable(right, variable_name)
    FunctionCall(_, args) => {
      for arg in args {
        if expr_contains_variable(arg, variable_name) {
          return true
        }
      }
      false
    }
  }
}

///|
fn contains_diff_fallback(expr : Expr) -> Bool {
  match expr {
    FunctionCall(name, args) =>
      if name == "diff_call" {
        true
      } else {
        for arg in args {
          if contains_diff_fallback(arg) {
            return true
          }
        }
        false
      }
    Unary(_, inner) => contains_diff_fallback(inner)
    Binary(_, left, right) =>
      contains_diff_fallback(left) || contains_diff_fallback(right)
    _ => false
  }
}

///|
fn normalize_negation(expr : Expr) -> Expr {
  let (base, flipped) = strip_negation(expr)
  if flipped {
    Unary(Neg, base)
  } else {
    base
  }
}

///|
fn strip_negation(expr : Expr) -> (Expr, Bool) {
  match expr {
    Unary(Neg, inner) => {
      let (base, flipped) = strip_negation(inner)
      (base, !flipped)
    }
    other => (other, false)
  }
}

///|
fn leading_coeff_fallback(variable_name : String, expr : Expr) -> Expr {
  Expr::FunctionCall("leading_coeff".to_string(), [
    sym(variable_name),
    normalize_negation(simplify(expr)),
  ])
}
