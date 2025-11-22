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
    Constant(_) => int(0)
    Symbol(symbol) => if symbol.name == variable_name { int(1) } else { int(0) }
    Unary(op, inner) =>
      match op {
        Neg => {
          let var_for_inner = variable_name
          Unary(Neg, differentiate(inner, var_for_inner))
        }
        Sin => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let cos_inner = Expr::Unary(Cos, inner)
          Binary(Mul, cos_inner, inner_diff)
        }
        Cos => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let sin_inner = Expr::Unary(Sin, inner)
          let neg_sin = Expr::Unary(Neg, sin_inner)
          Binary(Mul, neg_sin, inner_diff)
        }
        Tan => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let cos_inner = Expr::Unary(Cos, inner)
          let cos_sq = Expr::Binary(Pow, cos_inner, int(2))
          let sec_sq = Expr::Binary(Div, int(1), cos_sq)
          Binary(Mul, sec_sq, inner_diff)
        }
        Asin => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let inner_sq = Expr::Binary(Pow, inner, int(2))
          let base = Expr::Binary(Sub, int(1), inner_sq)
          let denom = Expr::Binary(Pow, base, double(0.5))
          Binary(Div, inner_diff, denom)
        }
        Acos => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let inner_sq = Expr::Binary(Pow, inner, int(2))
          let base = Expr::Binary(Sub, int(1), inner_sq)
          let denom = Expr::Binary(Pow, base, double(0.5))
          let neg_diff = Expr::Unary(Neg, inner_diff)
          Binary(Div, neg_diff, denom)
        }
        Atan => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let inner_sq = Expr::Binary(Pow, inner, int(2))
          let denom = Expr::Binary(Add, int(1), inner_sq)
          Binary(Div, inner_diff, denom)
        }
        Sinh => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let cosh_inner = Expr::Unary(Cosh, inner)
          Binary(Mul, cosh_inner, inner_diff)
        }
        Cosh => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let sinh_inner = Expr::Unary(Sinh, inner)
          Binary(Mul, sinh_inner, inner_diff)
        }
        Tanh => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let cosh_inner = Expr::Unary(Cosh, inner)
          let cosh_sq = Expr::Binary(Pow, cosh_inner, int(2))
          let sech_sq = Expr::Binary(Div, int(1), cosh_sq)
          Binary(Mul, sech_sq, inner_diff)
        }
        Asinh => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let inner_sq = Expr::Binary(Pow, inner, int(2))
          let base = Expr::Binary(Add, inner_sq, int(1))
          let denom = Expr::Binary(Pow, base, double(0.5))
          Binary(Div, inner_diff, denom)
        }
        Acosh => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let minus_one = Expr::Binary(Sub, inner, int(1))
          let plus_one = Expr::Binary(Add, inner, int(1))
          let sqrt_minus = Expr::Binary(Pow, minus_one, double(0.5))
          let sqrt_plus = Expr::Binary(Pow, plus_one, double(0.5))
          let denom = Expr::Binary(Mul, sqrt_minus, sqrt_plus)
          Binary(Div, inner_diff, denom)
        }
        Atanh => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let inner_sq = Expr::Binary(Pow, inner, int(2))
          let denom = Expr::Binary(Sub, int(1), inner_sq)
          Binary(Div, inner_diff, denom)
        }
        Exp => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let exp_inner = Expr::Unary(Exp, inner)
          Binary(Mul, exp_inner, inner_diff)
        }
        Log => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          Expr::Binary(Div, inner_diff, inner)
        }
        Abs => {
          let var_for_inner = variable_name
          let inner_diff = differentiate(inner, var_for_inner)
          let abs_inner = Expr::Unary(Abs, inner)
          let normalized = Expr::Binary(Div, inner, abs_inner)
          Binary(Mul, normalized, inner_diff)
        }
      }
    Binary(Add, left, right) => {
      let var_left = variable_name
      let var_right = variable_name
      let left_diff = differentiate(left, var_left)
      let right_diff = differentiate(right, var_right)
      Binary(Add, left_diff, right_diff)
    }
    Binary(Sub, left, right) => {
      let var_left = variable_name
      let var_right = variable_name
      let left_diff = differentiate(left, var_left)
      let right_diff = differentiate(right, var_right)
      Binary(Sub, left_diff, right_diff)
    }
    Binary(Mul, left, right) => {
      let var_left = variable_name
      let var_right = variable_name
      let left_diff = differentiate(left, var_left)
      let right_diff = differentiate(right, var_right)
      let term_left = Expr::Binary(Mul, left, right_diff)
      let term_right = Expr::Binary(Mul, left_diff, right)
      Binary(Add, term_left, term_right)
    }
    Binary(Div, left, right) => {
      let var_left = variable_name
      let var_right = variable_name
      let left_diff = differentiate(left, var_left)
      let right_diff = differentiate(right, var_right)
      let numerator_left = Expr::Binary(Mul, left_diff, right)
      let numerator_right = Expr::Binary(Mul, left, right_diff)
      let numerator = Expr::Binary(Sub, numerator_left, numerator_right)
      let denominator_squared = Expr::Binary(Pow, right, int(2))
      Binary(Div, numerator, denominator_squared)
    }
    Binary(Pow, base, exponent) =>
      match exponent {
        Constant(ConstantLiteral::Integer(exp_value)) =>
          if exp_value == 0 {
            int(0)
          } else {
            let exponent_expr = int(exp_value)
            diff_pow_general(base, exponent_expr, variable_name)
          }
        Constant(ConstantLiteral::Float(exp_value)) =>
          if exp_value == 0.0 {
            int(0)
          } else {
            let exponent_expr = double(exp_value)
            diff_pow_general(base, exponent_expr, variable_name)
          }
        other_exponent => diff_pow_general(base, other_exponent, variable_name)
      }
    FunctionCall(name, args) => {
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
  let log_base = Expr::Unary(Log, base)
  let exponent_diff_term = Expr::Binary(Mul, exponent_diff, log_base)
  let base_ratio = Expr::Binary(Div, base_diff, base)
  let exponent_term = Expr::Binary(Mul, exponent, base_ratio)
  let inner_sum = Expr::Binary(Add, exponent_diff_term, exponent_term)
  let pow_expr = Expr::Binary(Pow, base, exponent)
  Binary(Mul, pow_expr, inner_sum)
}

///|
