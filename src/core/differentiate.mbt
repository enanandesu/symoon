///|
pub fn differentiate(expr : Expr, variable_name : String) -> Expr {
  match expr {
    Expr::Int(_) => Expr::Int(0)
    Expr::Double(_) => Expr::Int(0)
    Expr::Symbol(symbol) =>
      if symbol.name == variable_name {
        Expr::Int(1)
      } else {
        Expr::Int(0)
      }
    Expr::Unary(UnaryOp::Neg, inner) => {
      let var_for_inner = variable_name
      Expr::Unary(UnaryOp::Neg, differentiate(inner, var_for_inner))
    }
    Expr::Unary(_, inner) =>
      diff_fallback(variable_name, inner, "diff_unary".to_string())
    Expr::Binary(BinaryOp::Add, left, right) => {
      let var_left = variable_name
      let var_right = variable_name
      let left_diff = differentiate(left, var_left)
      let right_diff = differentiate(right, var_right)
      Expr::Binary(BinaryOp::Add, left_diff, right_diff)
    }
    Expr::Binary(BinaryOp::Sub, left, right) => {
      let var_left = variable_name
      let var_right = variable_name
      let left_diff = differentiate(left, var_left)
      let right_diff = differentiate(right, var_right)
      Expr::Binary(BinaryOp::Sub, left_diff, right_diff)
    }
    Expr::Binary(BinaryOp::Mul, left, right) => {
      let var_left = variable_name
      let var_right = variable_name
      let left_diff = differentiate(left, var_left)
      let right_diff = differentiate(right, var_right)
      let term_left = Expr::Binary(BinaryOp::Mul, left, right_diff)
      let term_right = Expr::Binary(BinaryOp::Mul, left_diff, right)
      Expr::Binary(BinaryOp::Add, term_left, term_right)
    }
    Expr::Binary(BinaryOp::Div, left, right) => {
      let var_left = variable_name
      let var_right = variable_name
      let left_diff = differentiate(left, var_left)
      let right_diff = differentiate(right, var_right)
      let numerator_left = Expr::Binary(BinaryOp::Mul, left_diff, right)
      let numerator_right = Expr::Binary(BinaryOp::Mul, left, right_diff)
      let numerator = Expr::Binary(
        BinaryOp::Sub,
        numerator_left,
        numerator_right,
      )
      let denominator_squared = Expr::Binary(BinaryOp::Pow, right, Expr::Int(2))
      Expr::Binary(BinaryOp::Div, numerator, denominator_squared)
    }
    Expr::Binary(BinaryOp::Pow, base, exponent) =>
      match exponent {
        Expr::Int(exp_value) =>
          if exp_value == 0 {
            Expr::Int(0)
          } else {
            let exponent_expr = Expr::Int(exp_value)
            diff_pow_general(base, exponent_expr, variable_name)
          }
        Expr::Double(exp_value) =>
          if exp_value == 0.0 {
            Expr::Int(0)
          } else {
            let exponent_expr = Expr::Double(exp_value)
            diff_pow_general(base, exponent_expr, variable_name)
          }
        other_exponent => diff_pow_general(base, other_exponent, variable_name)
      }
    Expr::FunctionCall(name, args) => {
      let call_expr = Expr::FunctionCall(name, args)
      diff_fallback(variable_name, call_expr, "diff_call".to_string())
    }
  }
}

///|
fn diff_fallback(variable_name : String, expr : Expr, tag : String) -> Expr {
  let args = [sym(variable_name), expr]
  Expr::FunctionCall(tag, args)
}

///|
fn diff_pow_general(
  base : Expr,
  exponent : Expr,
  variable_name : String,
) -> Expr {
  let var_for_base = variable_name
  let var_for_exponent = variable_name
  let base_diff = differentiate(base, var_for_base)
  let exponent_diff = differentiate(exponent, var_for_exponent)
  let log_base = Expr::Unary(UnaryOp::Log, base)
  let exponent_diff_term = Expr::Binary(BinaryOp::Mul, exponent_diff, log_base)
  let base_ratio = Expr::Binary(BinaryOp::Div, base_diff, base)
  let exponent_term = Expr::Binary(BinaryOp::Mul, exponent, base_ratio)
  let inner_sum = Expr::Binary(BinaryOp::Add, exponent_diff_term, exponent_term)
  let pow_expr = Expr::Binary(BinaryOp::Pow, base, exponent)
  Expr::Binary(BinaryOp::Mul, pow_expr, inner_sum)
}
