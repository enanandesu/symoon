///|
pub enum LimitDirection {
  Both
  FromLeft
  FromRight
} derive(Eq, Show)

///|
pub enum LimitResult {
  Value(Expr)
  PosInf
  NegInf
  Divergent
  Unknown
} derive(Eq, Show)

///|
priv enum Sign {
  Positive
  Negative
} derive(Eq)

///|
pub enum IndeterminateForm {
  ZeroOverZero
  InfinityOverInfinity
  ZeroTimesInfinity
  InfinityMinusInfinity
  OnePowerInfinity
  ZeroPowerZero
  InfinityPowerZero
  Oscillatory
} derive(Eq, Show)

///|
pub fn limit(
  expr : Expr,
  variable_name : String,
  point : Expr,
  dir? : LimitDirection = Both,
) -> LimitResult {
  let normalized = simplify(expr)
  let target_point = simplify(point)
  match
    try_direct_substitution(
      normalized.copy(),
      variable_name,
      target_point.copy(),
    ) {
    Some(result) => result
    None => perform_limit(normalized, variable_name, target_point, dir)
  }
}

///|
pub fn limit_left(
  expr : Expr,
  variable_name : String,
  point : Expr,
) -> LimitResult {
  limit(expr, variable_name, point, dir=LimitDirection::FromLeft)
}

///|
pub fn limit_right(
  expr : Expr,
  variable_name : String,
  point : Expr,
) -> LimitResult {
  limit(expr, variable_name, point, dir=LimitDirection::FromRight)
}

///|
fn perform_limit(
  expr : Expr,
  variable_name : String,
  point : Expr,
  dir : LimitDirection,
) -> LimitResult {
  match
    detect_simple_divergence(expr.copy(), variable_name, point.copy(), dir) {
    Some(result) => result
    None => {
      let _ = detect_indeterminate_form(
        expr.copy(),
        variable_name,
        point.copy(),
      )
      // TODO: plug in dominant-term analysis / series expansion / l'Hopital
      LimitResult::Unknown
    }
  }
}

///|
fn try_direct_substitution(
  expr : Expr,
  variable_name : String,
  point : Expr,
) -> LimitResult? {
  let substituted = simplify(
    limit_substitute_variable(expr, variable_name, point),
  )
  match substituted {
    Constant(ConstantLiteral::Integer(_))
    | Constant(ConstantLiteral::Float(_)) =>
      Some(LimitResult::Value(substituted))
    _ => None
  }
}

///|
fn detect_simple_divergence(
  expr : Expr,
  variable_name : String,
  point : Expr,
  dir : LimitDirection,
) -> LimitResult? {
  match expr {
    Binary(Div, left, right) => {
      let denom_expr = right.copy()
      let numer = simplify(
        limit_substitute_variable(left, variable_name, point),
      )
      let denom = simplify(
        limit_substitute_variable(right, variable_name, point),
      )
      if limit_is_zero_literal(denom) {
        if limit_is_zero_literal(numer) {
          None
        } else {
          match
            determine_directional_infinity(
              numer, denom_expr, variable_name, point, dir,
            ) {
            Some(result) => Some(result)
            None => Some(LimitResult::Divergent)
          }
        }
      } else {
        None
      }
    }
    _ => None
  }
}

///|
fn detect_indeterminate_form(
  expr : Expr,
  variable_name : String,
  point : Expr,
) -> IndeterminateForm? {
  match expr {
    Binary(Div, left, right) => {
      let denom = simplify(
        limit_substitute_variable(right, variable_name, point),
      )
      let numer = simplify(
        limit_substitute_variable(left, variable_name, point),
      )
      if limit_is_zero_literal(numer) && limit_is_zero_literal(denom) {
        Some(IndeterminateForm::ZeroOverZero)
      } else {
        None
      }
    }
    Binary(Sub, left, right) => {
      let lhs = simplify(limit_substitute_variable(left, variable_name, point))
      let rhs = simplify(limit_substitute_variable(right, variable_name, point))
      let lhs_inf = limit_detects_infinite_literal(lhs)
      let rhs_inf = limit_detects_infinite_literal(rhs)
      if lhs_inf && rhs_inf {
        Some(IndeterminateForm::InfinityMinusInfinity)
      } else {
        None
      }
    }
    Binary(Mul, left, right) => {
      let lhs = simplify(limit_substitute_variable(left, variable_name, point))
      let rhs = simplify(limit_substitute_variable(right, variable_name, point))
      let lhs_zero = limit_is_zero_literal(lhs)
      let rhs_zero = limit_is_zero_literal(rhs)
      let lhs_inf = limit_detects_infinite_literal(lhs)
      let rhs_inf = limit_detects_infinite_literal(rhs)
      if lhs_zero && rhs_inf {
        Some(IndeterminateForm::ZeroTimesInfinity)
      } else if rhs_zero && lhs_inf {
        Some(IndeterminateForm::ZeroTimesInfinity)
      } else {
        None
      }
    }
    Binary(Pow, base, exponent) => {
      let base_value = simplify(
        limit_substitute_variable(base, variable_name, point),
      )
      let exponent_value = simplify(
        limit_substitute_variable(exponent, variable_name, point),
      )
      let base_one = limit_is_one_literal(base_value)
      let base_zero = limit_is_zero_literal(base_value)
      let base_inf = limit_detects_infinite_literal(base_value)
      let exp_zero = limit_is_zero_literal(exponent_value)
      let exp_inf = limit_detects_infinite_literal(exponent_value)
      if base_one && exp_inf {
        Some(IndeterminateForm::OnePowerInfinity)
      } else if base_zero && exp_zero {
        Some(IndeterminateForm::ZeroPowerZero)
      } else if base_inf && exp_zero {
        Some(IndeterminateForm::InfinityPowerZero)
      } else {
        None
      }
    }
    _ => None
  }
}

///|
fn limit_substitute_variable(
  expr : Expr,
  variable_name : String,
  replacement : Expr,
) -> Expr {
  match expr {
    Constant(_) => expr
    Symbol(symbol) =>
      if symbol.name == variable_name {
        replacement.copy()
      } else {
        expr
      }
    Unary(op, inner) => {
      let substituted = limit_substitute_variable(
        inner, variable_name, replacement,
      )
      Unary(op, substituted)
    }
    Binary(op, left, right) => {
      let new_left = limit_substitute_variable(left, variable_name, replacement)
      let new_right = limit_substitute_variable(
        right, variable_name, replacement,
      )
      Binary(op, new_left, new_right)
    }
    FunctionCall(name, args) => {
      let new_args = args.map((arg : Expr) => limit_substitute_variable(
        arg, variable_name, replacement,
      ))
      FunctionCall(name, new_args)
    }
  }
}

///|
fn limit_is_zero_literal(expr : Expr) -> Bool {
  match expr {
    Constant(ConstantLiteral::Integer(value)) => value == 0
    Constant(ConstantLiteral::Float(value)) => value == 0.0
    _ => false
  }
}

///|
fn limit_is_one_literal(expr : Expr) -> Bool {
  match expr {
    Constant(ConstantLiteral::Integer(value)) => value == 1
    Constant(ConstantLiteral::Float(value)) => value == 1.0
    _ => false
  }
}

///|
fn limit_detects_infinite_literal(expr : Expr) -> Bool {
  match expr {
    Constant(ConstantLiteral::PosInfinity) => true
    Constant(ConstantLiteral::NegInfinity) => true
    // Fallback for legacy placeholders
    FunctionCall(name, _) => name == "Infinity" || name == "oo"
    _ => false
  }
}

///|
fn determine_directional_infinity(
  numerator : Expr,
  denom_expr : Expr,
  variable_name : String,
  point : Expr,
  dir : LimitDirection,
) -> LimitResult? {
  let numer_sign = match limit_literal_sign(numerator) {
    Some(sign) => sign
    None => return None
  }
  let denom_signs = match
    limit_directional_sign(denom_expr, variable_name, point) {
    Some(signs) => signs
    None => return None
  }
  let (left_sign, right_sign) = denom_signs
  match dir {
    LimitDirection::Both =>
      if left_sign == right_sign {
        Some(limit_result_from_sign(multiply_signs(numer_sign, left_sign)))
      } else {
        None
      }
    LimitDirection::FromLeft =>
      Some(limit_result_from_sign(multiply_signs(numer_sign, left_sign)))
    LimitDirection::FromRight =>
      Some(limit_result_from_sign(multiply_signs(numer_sign, right_sign)))
  }
}

///|
fn limit_result_from_sign(sign : Sign) -> LimitResult {
  match sign {
    Sign::Positive => LimitResult::PosInf
    Sign::Negative => LimitResult::NegInf
  }
}

///|
fn multiply_signs(lhs : Sign, rhs : Sign) -> Sign {
  if lhs == rhs {
    Sign::Positive
  } else {
    Sign::Negative
  }
}

///|
fn flip_sign(sign : Sign) -> Sign {
  match sign {
    Sign::Positive => Sign::Negative
    Sign::Negative => Sign::Positive
  }
}

///|
fn limit_literal_sign(expr : Expr) -> Sign? {
  match expr {
    Constant(ConstantLiteral::Integer(value)) =>
      if value > 0 {
        Some(Sign::Positive)
      } else if value < 0 {
        Some(Sign::Negative)
      } else {
        None
      }
    Constant(ConstantLiteral::Float(value)) =>
      if value > 0.0 {
        Some(Sign::Positive)
      } else if value < 0.0 {
        Some(Sign::Negative)
      } else {
        None
      }
    Constant(ConstantLiteral::PosInfinity) => Some(Sign::Positive)
    Constant(ConstantLiteral::NegInfinity) => Some(Sign::Negative)
    Unary(UnaryOp::Neg, inner) =>
      match limit_literal_sign(inner) {
        Some(sign) => Some(flip_sign(sign))
        None => None
      }
    _ => None
  }
}

///|
fn limit_directional_sign(
  expr : Expr,
  variable_name : String,
  point : Expr,
) -> (Sign, Sign)? {
  match expr {
    Constant(ConstantLiteral::Integer(value)) =>
      if value > 0 {
        Some((Sign::Positive, Sign::Positive))
      } else if value < 0 {
        Some((Sign::Negative, Sign::Negative))
      } else {
        None
      }
    Constant(ConstantLiteral::Float(value)) =>
      if value > 0.0 {
        Some((Sign::Positive, Sign::Positive))
      } else if value < 0.0 {
        Some((Sign::Negative, Sign::Negative))
      } else {
        None
      }
    Constant(ConstantLiteral::PosInfinity) =>
      Some((Sign::Positive, Sign::Positive))
    Constant(ConstantLiteral::NegInfinity) =>
      Some((Sign::Negative, Sign::Negative))
    Unary(UnaryOp::Neg, inner) =>
      match limit_directional_sign(inner, variable_name, point) {
        Some((left, right)) => Some((flip_sign(left), flip_sign(right)))
        None => None
      }
    Binary(BinaryOp::Sub, left, right) =>
      match (left, right) {
        (Expr::Symbol(symbol), other) if symbol.name == variable_name =>
          if limit_expr_equals(other, point) {
            Some((Sign::Negative, Sign::Positive))
          } else {
            None
          }
        (other, Expr::Symbol(symbol)) if symbol.name == variable_name =>
          if limit_expr_equals(other, point) {
            Some((Sign::Positive, Sign::Negative))
          } else {
            None
          }
        _ => None
      }
    _ => None
  }
}

///|
fn limit_expr_equals(lhs : Expr, rhs : Expr) -> Bool {
  if lhs == rhs {
    return true
  }
  match (lhs, rhs) {
    (
      Constant(ConstantLiteral::Integer(left)),
      Constant(ConstantLiteral::Float(right)),
    ) => left.to_double() == right
    (
      Constant(ConstantLiteral::Float(left)),
      Constant(ConstantLiteral::Integer(right)),
    ) => left == right.to_double()
    _ => false
  }
}
