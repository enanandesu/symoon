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
    None =>
      match
        detect_indeterminate_form(expr.copy(), variable_name, point.copy()) {
        Some(_) =>
          match resolve_with_single_taylor(expr, variable_name, point, dir) {
            Some(result) => result
            None => LimitResult::Unknown
          }
        None => LimitResult::Unknown
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
      Some(LimitResult::Value(rationalize_expr(substituted)))
    _ =>
      match limit_eval_literal(substituted.copy()) {
        Some(literal) =>
          Some(LimitResult::Value(rationalize_expr(Constant(literal))))
        None => None
      }
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
      let numer_literal_sign = limit_literal_sign(numer.copy())
      if limit_is_zero_literal(denom) {
        if limit_is_zero_literal(numer) {
          None
        } else {
          match
            determine_directional_infinity(
              numer, denom_expr, variable_name, point, dir,
            ) {
            Some(result) => Some(result)
            None =>
              match numer_literal_sign {
                Some(_) => Some(LimitResult::Divergent)
                None => None
              }
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
    Binary(Div, left, right) =>
      classify_div_indeterminate(left, right, variable_name, point)
    Binary(Add, left, right) =>
      classify_add_indeterminate(left, right, variable_name, point)
    Binary(Sub, left, right) =>
      classify_sub_indeterminate(left, right, variable_name, point)
    Binary(Mul, left, right) =>
      classify_mul_indeterminate(left, right, variable_name, point)
    Binary(Pow, base, exponent) =>
      classify_pow_indeterminate(base, exponent, variable_name, point)
    Unary(op, inner) =>
      classify_unary_indeterminate(op, inner, variable_name, point)
    _ => None
  }
}

///|
fn classify_div_indeterminate(
  left : Expr,
  right : Expr,
  variable_name : String,
  point : Expr,
) -> IndeterminateForm? {
  let denom = simplify(limit_substitute_variable(right, variable_name, point))
  let numer = simplify(limit_substitute_variable(left, variable_name, point))
  if limit_is_zero_literal(numer) && limit_is_zero_literal(denom) {
    return Some(IndeterminateForm::ZeroOverZero)
  }
  match (limit_infinite_sign(numer), limit_infinite_sign(denom)) {
    (Some(_), Some(_)) => Some(IndeterminateForm::InfinityOverInfinity)
    _ => None
  }
}

///|
fn classify_add_indeterminate(
  left : Expr,
  right : Expr,
  variable_name : String,
  point : Expr,
) -> IndeterminateForm? {
  let lhs = simplify(limit_substitute_variable(left, variable_name, point))
  let rhs = simplify(limit_substitute_variable(right, variable_name, point))
  match (limit_infinite_sign(lhs), limit_infinite_sign(rhs)) {
    (Some(left_sign), Some(right_sign)) =>
      if left_sign != right_sign {
        Some(IndeterminateForm::InfinityMinusInfinity)
      } else {
        None
      }
    _ => None
  }
}

///|
fn classify_sub_indeterminate(
  left : Expr,
  right : Expr,
  variable_name : String,
  point : Expr,
) -> IndeterminateForm? {
  let lhs = simplify(limit_substitute_variable(left, variable_name, point))
  let rhs = simplify(limit_substitute_variable(right, variable_name, point))
  if limit_detects_infinite_literal(lhs) && limit_detects_infinite_literal(rhs) {
    Some(IndeterminateForm::InfinityMinusInfinity)
  } else {
    None
  }
}

///|
fn classify_mul_indeterminate(
  left : Expr,
  right : Expr,
  variable_name : String,
  point : Expr,
) -> IndeterminateForm? {
  let lhs = simplify(limit_substitute_variable(left, variable_name, point))
  let rhs = simplify(limit_substitute_variable(right, variable_name, point))
  let lhs_zero = limit_is_zero_literal(lhs)
  let rhs_zero = limit_is_zero_literal(rhs)
  let lhs_inf = limit_detects_infinite_literal(lhs)
  let rhs_inf = limit_detects_infinite_literal(rhs)
  if (lhs_zero && rhs_inf) || (rhs_zero && lhs_inf) {
    Some(IndeterminateForm::ZeroTimesInfinity)
  } else {
    None
  }
}

///|
fn classify_pow_indeterminate(
  base : Expr,
  exponent : Expr,
  variable_name : String,
  point : Expr,
) -> IndeterminateForm? {
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

///|
fn classify_unary_indeterminate(
  op : UnaryOp,
  inner : Expr,
  variable_name : String,
  point : Expr,
) -> IndeterminateForm? {
  if op == Sin || op == Cos {
    match limit_directional_sign(inner, variable_name, point) {
      Some(_) => Some(IndeterminateForm::Oscillatory)
      None => None
    }
  } else {
    None
  }
}

///|
pub fn classify_indeterminate(
  expr : Expr,
  variable_name : String,
  point : Expr,
) -> IndeterminateForm? {
  detect_indeterminate_form(simplify(expr), variable_name, simplify(point))
}

///|
fn resolve_with_single_taylor(
  expr : Expr,
  variable_name : String,
  point : Expr,
  dir : LimitDirection,
) -> LimitResult? {
  match
    attempt_linear_then_eval(expr.copy(), variable_name, point.copy(), dir, 3) {
    Some(result) => Some(result)
    None => attempt_lhopital_chain(expr, variable_name, point, dir, 3)
  }
}

///|
fn attempt_linear_then_eval(
  expr : Expr,
  variable_name : String,
  point : Expr,
  dir : LimitDirection,
  remaining_lhopital : Int,
) -> LimitResult? {
  match attempt_taylor_linearization(expr, variable_name, point.copy()) {
    Some(expanded) =>
      match
        evaluate_limit_candidate(
          expanded.copy(),
          variable_name,
          point.copy(),
          dir,
        ) {
        Some(result) => Some(result)
        None =>
          if remaining_lhopital > 0 {
            attempt_lhopital_chain(
              expanded, variable_name, point, dir, remaining_lhopital,
            )
          } else {
            None
          }
      }
    None => None
  }
}

///|
fn attempt_taylor_linearization(
  expr : Expr,
  variable_name : String,
  point : Expr,
) -> Expr? {
  let (rewritten, changed) = taylor_linearize_expr(expr, variable_name, point)
  if changed {
    Some(simplify(rewritten))
  } else {
    None
  }
}

///|
fn taylor_linearize_expr(
  expr : Expr,
  variable_name : String,
  point : Expr,
) -> (Expr, Bool) {
  match expr {
    Constant(_) => (expr, false)
    Symbol(_) => (expr, false)
    Unary(op, inner) => {
      let (new_inner, inner_changed) = taylor_linearize_expr(
        inner,
        variable_name,
        point.copy(),
      )
      match maybe_linearize_unary(op, new_inner.copy(), variable_name, point) {
        Some(replacement) => (replacement, true)
        None => (Unary(op, new_inner), inner_changed)
      }
    }
    Binary(op, left, right) => {
      let (new_left, left_changed) = taylor_linearize_expr(
        left,
        variable_name,
        point.copy(),
      )
      let (new_right, right_changed) = taylor_linearize_expr(
        right,
        variable_name,
        point.copy(),
      )
      (Binary(op, new_left, new_right), left_changed || right_changed)
    }
    FunctionCall(name, args) => {
      let rewritten = Array::new(capacity=args.length())
      let mut any_changed = false
      for arg in args {
        let (new_arg, changed) = taylor_linearize_expr(
          arg,
          variable_name,
          point.copy(),
        )
        rewritten.push(new_arg)
        if changed {
          any_changed = true
        }
      }
      (FunctionCall(name, rewritten), any_changed)
    }
  }
}

///|
fn maybe_linearize_unary(
  op : UnaryOp,
  inner : Expr,
  variable_name : String,
  point : Expr,
) -> Expr? {
  let substituted = simplify(
    limit_substitute_variable(inner.copy(), variable_name, point.copy()),
  )
  match op {
    UnaryOp::Sin
    | UnaryOp::Tan
    | UnaryOp::Sinh
    | UnaryOp::Tanh
    | UnaryOp::Asin
    | UnaryOp::Atan
    | UnaryOp::Asinh
    | UnaryOp::Atanh =>
      if limit_is_zero_literal(substituted) {
        Some(inner)
      } else {
        None
      }
    UnaryOp::Exp =>
      if limit_is_zero_literal(substituted) {
        Some(add(int(1), inner))
      } else {
        None
      }
    UnaryOp::Log =>
      if limit_is_one_literal(substituted) {
        Some(sub(inner, int(1)))
      } else {
        None
      }
    UnaryOp::Cos | UnaryOp::Cosh =>
      if limit_is_zero_literal(substituted) {
        let squared = pow(inner.copy(), int(2))
        let half = div(squared, int(2))
        Some(sub(int(1), half))
      } else {
        None
      }
    _ => None
  }
}

///|
fn evaluate_limit_candidate(
  expr : Expr,
  variable_name : String,
  point : Expr,
  dir : LimitDirection,
) -> LimitResult? {
  match try_direct_substitution(expr.copy(), variable_name, point.copy()) {
    Some(result) => Some(result)
    None => detect_simple_divergence(expr, variable_name, point.copy(), dir)
  }
}

///|
fn attempt_lhopital_once(
  expr : Expr,
  variable_name : String,
  point : Expr,
) -> Expr? {
  match expr {
    Binary(Div, left, right) =>
      match
        detect_indeterminate_form(expr.copy(), variable_name, point.copy()) {
        Some(form) => {
          let applicable = form == IndeterminateForm::ZeroOverZero ||
            form == IndeterminateForm::InfinityOverInfinity
          if applicable {
            let numerator_derivative = simplify(
              differentiate(left, variable_name),
            )
            let denominator_derivative = simplify(
              differentiate(right, variable_name),
            )
            Some(
              Expr::Binary(
                BinaryOp::Div,
                numerator_derivative,
                denominator_derivative,
              ),
            )
          } else {
            None
          }
        }
        None => None
      }
    _ => None
  }
}

///|
fn attempt_lhopital_chain(
  expr : Expr,
  variable_name : String,
  point : Expr,
  dir : LimitDirection,
  remaining_steps : Int,
) -> LimitResult? {
  if remaining_steps <= 0 {
    return None
  }
  match detect_indeterminate_form(expr.copy(), variable_name, point.copy()) {
    Some(form) =>
      if form == IndeterminateForm::ZeroOverZero ||
        form == IndeterminateForm::InfinityOverInfinity {
        match attempt_lhopital_once(expr, variable_name, point.copy()) {
          Some(derived) => {
            let simplified = simplify(derived)
            match
              evaluate_limit_candidate(
                simplified.copy(),
                variable_name,
                point.copy(),
                dir,
              ) {
              Some(result) => Some(result)
              None =>
                match
                  attempt_linear_then_eval(
                    simplified.copy(),
                    variable_name,
                    point.copy(),
                    dir,
                    remaining_steps - 1,
                  ) {
                  Some(result) => Some(result)
                  None =>
                    attempt_lhopital_chain(
                      simplified,
                      variable_name,
                      point,
                      dir,
                      remaining_steps - 1,
                    )
                }
            }
          }
          None => None
        }
      } else {
        None
      }
    None => None
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
    _ =>
      match limit_eval_literal(expr) {
        Some(literal) => limit_literal_is_zero(literal)
        None => false
      }
  }
}

///|
fn limit_is_one_literal(expr : Expr) -> Bool {
  match expr {
    Constant(ConstantLiteral::Integer(value)) => value == 1
    Constant(ConstantLiteral::Float(value)) => value == 1.0
    _ =>
      match limit_eval_literal(expr) {
        Some(literal) => limit_literal_is_one(literal)
        None => false
      }
  }
}

///|
fn limit_detects_infinite_literal(expr : Expr) -> Bool {
  match limit_infinite_sign(expr) {
    Some(_) => true
    None =>
      match expr {

        // Fallback for legacy placeholders

        FunctionCall(name, _) => name == "Infinity" || name == "oo"
        _ => false
      }
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
    Binary(BinaryOp::Div, numerator, denominator) => {
      let substituted = simplify(
        limit_substitute_variable(denominator, variable_name, point),
      )
      if !limit_is_zero_literal(substituted) {
        return None
      }
      match
        (
          limit_literal_sign(numerator),
          limit_directional_sign(denominator, variable_name, point),
        ) {
        (Some(num_sign), Some((left, right))) =>
          Some(
            (multiply_signs(num_sign, left), multiply_signs(num_sign, right)),
          )
        _ => None
      }
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

///|
fn limit_infinite_sign(expr : Expr) -> Sign? {
  match expr {
    Constant(ConstantLiteral::PosInfinity) => Some(Sign::Positive)
    Constant(ConstantLiteral::NegInfinity) => Some(Sign::Negative)
    Unary(UnaryOp::Neg, inner) =>
      match limit_infinite_sign(inner) {
        Some(sign) => Some(flip_sign(sign))
        None => None
      }
    _ => None
  }
}

///|
fn limit_eval_literal(expr : Expr) -> ConstantLiteral? {
  match expr {
    Constant(literal) => Some(literal)
    Unary(op, inner) =>
      match limit_eval_literal(inner) {
        Some(value) => limit_eval_unary(op, value)
        None => None
      }
    Binary(op, left, right) =>
      match (limit_eval_literal(left), limit_eval_literal(right)) {
        (Some(lhs), Some(rhs)) => limit_eval_binary(op, lhs, rhs)
        _ => None
      }
    _ => None
  }
}

///|
fn limit_eval_unary(
  op : UnaryOp,
  literal : ConstantLiteral,
) -> ConstantLiteral? {
  match op {
    UnaryOp::Neg =>
      match literal {
        ConstantLiteral::Integer(value) =>
          Some(ConstantLiteral::Integer(-value))
        ConstantLiteral::Float(value) => Some(ConstantLiteral::Float(-value))
        _ => None
      }
    UnaryOp::Sin
    | UnaryOp::Tan
    | UnaryOp::Sinh
    | UnaryOp::Tanh
    | UnaryOp::Asin
    | UnaryOp::Atan
    | UnaryOp::Asinh
    | UnaryOp::Atanh =>
      if limit_literal_is_zero(literal) {
        Some(ConstantLiteral::Integer(0))
      } else {
        None
      }
    UnaryOp::Cos | UnaryOp::Cosh =>
      if limit_literal_is_zero(literal) {
        Some(ConstantLiteral::Integer(1))
      } else {
        None
      }
    UnaryOp::Exp =>
      if limit_literal_is_zero(literal) {
        Some(ConstantLiteral::Integer(1))
      } else {
        None
      }
    UnaryOp::Log =>
      if limit_literal_is_one(literal) {
        Some(ConstantLiteral::Integer(0))
      } else {
        None
      }
    _ => None
  }
}

///|
fn limit_eval_binary(
  op : BinaryOp,
  lhs : ConstantLiteral,
  rhs : ConstantLiteral,
) -> ConstantLiteral? {
  match (limit_literal_to_double(lhs), limit_literal_to_double(rhs)) {
    (Some(left_value), Some(right_value)) =>
      match op {
        BinaryOp::Add => Some(limit_double_to_literal(left_value + right_value))
        BinaryOp::Sub => Some(limit_double_to_literal(left_value - right_value))
        BinaryOp::Mul => Some(limit_double_to_literal(left_value * right_value))
        BinaryOp::Div =>
          if right_value == 0.0 {
            None
          } else {
            Some(limit_double_to_literal(left_value / right_value))
          }
        BinaryOp::Pow =>
          Some(limit_double_to_literal(@math.pow(left_value, right_value)))
      }
    _ => None
  }
}

///|
fn limit_literal_to_double(literal : ConstantLiteral) -> Double? {
  match literal {
    ConstantLiteral::Integer(value) => Some(value.to_double())
    ConstantLiteral::Float(value) => Some(value)
    _ => None
  }
}

///|
fn limit_double_to_literal(value : Double) -> ConstantLiteral {
  let rounded = value.round()
  let difference = (value - rounded).abs()
  if difference < 1.0e-10 {
    ConstantLiteral::Integer(rounded.to_int())
  } else {
    ConstantLiteral::Float(value)
  }
}

///|
fn limit_literal_is_zero(literal : ConstantLiteral) -> Bool {
  match literal {
    ConstantLiteral::Integer(value) => value == 0
    ConstantLiteral::Float(value) => value == 0.0
    _ => false
  }
}

///|
fn limit_literal_is_one(literal : ConstantLiteral) -> Bool {
  match literal {
    ConstantLiteral::Integer(value) => value == 1
    ConstantLiteral::Float(value) => value == 1.0
    _ => false
  }
}
