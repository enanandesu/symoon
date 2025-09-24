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
    Expr::Binary(BinaryOp::Div, left, right) =>
      diff_fallback(
        variable_name,
        Expr::Binary(BinaryOp::Div, left, right),
        "diff_div".to_string(),
      )
    Expr::Binary(BinaryOp::Pow, base, exponent) =>
      diff_fallback(
        variable_name,
        Expr::Binary(BinaryOp::Pow, base, exponent),
        "diff_pow".to_string(),
      )
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
