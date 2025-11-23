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
  match
    try_direct_substitution(normalized.copy(), variable_name, point.copy()) {
    Some(result) => result
    None => perform_limit(normalized, variable_name, point, dir)
  }
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
  _dir : LimitDirection,
) -> LimitResult? {
  match expr {
    Binary(Div, left, right) => {
      let denom = simplify(
        limit_substitute_variable(right, variable_name, point),
      )
      let numer = simplify(
        limit_substitute_variable(left, variable_name, point),
      )
      if limit_is_zero_literal(denom) {
        if limit_is_zero_literal(numer) {
          None
        } else {
          Some(LimitResult::Divergent)
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
