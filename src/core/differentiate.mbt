///|
pub fn differentiate(
  expr : Expr,
  variable_name : String,
  order? : Int = 1,
) -> Expr {
  if order <= 0 {
    expr
  } else {
    differentiate_order(expr, variable_name, order)
  }
}

///|
fn differentiate_order(
  expr : Expr,
  variable_name : String,
  order : Int,
) -> Expr {
  let first_derivative = differentiate_once(expr, variable_name)
  if order == 1 {
    first_derivative
  } else {
    differentiate_order(first_derivative, variable_name, order - 1)
  }
}

///|
fn differentiate_once(expr : Expr, variable_name : String) -> Expr {
  match expr {
    Expr::Int(_) => Expr::Int(0)
    Expr::Double(_) => Expr::Int(0)
    Expr::Symbol(symbol) =>
      if symbol.name == variable_name {
        Expr::Int(1)
      } else {
        Expr::Int(0)
      }
    Expr::Unary(op, inner) =>
      match op {
        UnaryOp::Neg => {
          let var_for_inner = variable_name
          Expr::Unary(UnaryOp::Neg, differentiate(inner, var_for_inner))
        }
        UnaryOp::Sin => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let cos_inner = Expr::Unary(UnaryOp::Cos, inner)
          Expr::Binary(BinaryOp::Mul, cos_inner, inner_diff)
        }
        UnaryOp::Cos => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let sin_inner = Expr::Unary(UnaryOp::Sin, inner)
          let neg_sin = Expr::Unary(UnaryOp::Neg, sin_inner)
          Expr::Binary(BinaryOp::Mul, neg_sin, inner_diff)
        }
        UnaryOp::Tan => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let cos_inner = Expr::Unary(UnaryOp::Cos, inner)
          let cos_sq = Expr::Binary(BinaryOp::Pow, cos_inner, Expr::Int(2))
          let sec_sq = Expr::Binary(BinaryOp::Div, Expr::Int(1), cos_sq)
          Expr::Binary(BinaryOp::Mul, sec_sq, inner_diff)
        }
        UnaryOp::Asin => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let inner_sq = Expr::Binary(BinaryOp::Pow, inner, Expr::Int(2))
          let base = Expr::Binary(BinaryOp::Sub, Expr::Int(1), inner_sq)
          let denom = Expr::Binary(BinaryOp::Pow, base, Expr::Double(0.5))
          Expr::Binary(BinaryOp::Div, inner_diff, denom)
        }
        UnaryOp::Acos => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let inner_sq = Expr::Binary(BinaryOp::Pow, inner, Expr::Int(2))
          let base = Expr::Binary(BinaryOp::Sub, Expr::Int(1), inner_sq)
          let denom = Expr::Binary(BinaryOp::Pow, base, Expr::Double(0.5))
          let neg_diff = Expr::Unary(UnaryOp::Neg, inner_diff)
          Expr::Binary(BinaryOp::Div, neg_diff, denom)
        }
        UnaryOp::Atan => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let inner_sq = Expr::Binary(BinaryOp::Pow, inner, Expr::Int(2))
          let denom = Expr::Binary(BinaryOp::Add, Expr::Int(1), inner_sq)
          Expr::Binary(BinaryOp::Div, inner_diff, denom)
        }
        UnaryOp::Sinh => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let cosh_inner = Expr::Unary(UnaryOp::Cosh, inner)
          Expr::Binary(BinaryOp::Mul, cosh_inner, inner_diff)
        }
        UnaryOp::Cosh => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let sinh_inner = Expr::Unary(UnaryOp::Sinh, inner)
          Expr::Binary(BinaryOp::Mul, sinh_inner, inner_diff)
        }
        UnaryOp::Tanh => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let cosh_inner = Expr::Unary(UnaryOp::Cosh, inner)
          let cosh_sq = Expr::Binary(BinaryOp::Pow, cosh_inner, Expr::Int(2))
          let sech_sq = Expr::Binary(BinaryOp::Div, Expr::Int(1), cosh_sq)
          Expr::Binary(BinaryOp::Mul, sech_sq, inner_diff)
        }
        UnaryOp::Asinh => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let inner_sq = Expr::Binary(BinaryOp::Pow, inner, Expr::Int(2))
          let base = Expr::Binary(BinaryOp::Add, inner_sq, Expr::Int(1))
          let denom = Expr::Binary(BinaryOp::Pow, base, Expr::Double(0.5))
          Expr::Binary(BinaryOp::Div, inner_diff, denom)
        }
        UnaryOp::Acosh => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let minus_one = Expr::Binary(BinaryOp::Sub, inner, Expr::Int(1))
          let plus_one = Expr::Binary(BinaryOp::Add, inner, Expr::Int(1))
          let sqrt_minus = Expr::Binary(
            BinaryOp::Pow,
            minus_one,
            Expr::Double(0.5),
          )
          let sqrt_plus = Expr::Binary(
            BinaryOp::Pow,
            plus_one,
            Expr::Double(0.5),
          )
          let denom = Expr::Binary(BinaryOp::Mul, sqrt_minus, sqrt_plus)
          Expr::Binary(BinaryOp::Div, inner_diff, denom)
        }
        UnaryOp::Atanh => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let inner_sq = Expr::Binary(BinaryOp::Pow, inner, Expr::Int(2))
          let denom = Expr::Binary(BinaryOp::Sub, Expr::Int(1), inner_sq)
          Expr::Binary(BinaryOp::Div, inner_diff, denom)
        }
        UnaryOp::Exp => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let exp_inner = Expr::Unary(UnaryOp::Exp, inner)
          Expr::Binary(BinaryOp::Mul, exp_inner, inner_diff)
        }
        UnaryOp::Log => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          Expr::Binary(BinaryOp::Div, inner_diff, inner)
        }
        UnaryOp::Abs => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let abs_inner = Expr::Unary(UnaryOp::Abs, inner)
          let normalized = Expr::Binary(BinaryOp::Div, inner, abs_inner)
          Expr::Binary(BinaryOp::Mul, normalized, inner_diff)
        }
      }
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
