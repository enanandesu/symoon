///|
pub struct RationalConstant {
  symbol : Expr
  numeric : Double?
}

///|
pub fn RationalConstant::new(
  symbol : Expr,
  numeric : Double?,
) -> RationalConstant {
  { symbol, numeric }
}

///|
pub fn default_rational_constants() -> Array[RationalConstant] {
  let constants : Array[RationalConstant] = Array::new()
  constants.push(RationalConstant::new(sym("pi"), Some(3.141592653589793)))
  constants.push(RationalConstant::new(sym("Pi"), Some(3.141592653589793)))
  constants.push(RationalConstant::new(sym("tau"), Some(6.283185307179586)))
  constants.push(RationalConstant::new(sym("Tau"), Some(6.283185307179586)))
  constants.push(RationalConstant::new(sym("E"), Some(2.718281828459045)))
  constants.push(
    RationalConstant::new(sym("EulerGamma"), Some(0.5772156649015329)),
  )
  constants.push(RationalConstant::new(sym("Catalan"), Some(0.915965594177219)))
  constants.push(
    RationalConstant::new(sym("GoldenRatio"), Some(1.618033988749895)),
  )
  constants.push(
    RationalConstant::new(sym("GoldenRatioConjugate"), Some(0.6180339887498949)),
  )
  constants.push(
    RationalConstant::new(sym("SilverRatio"), Some(2.414213562373095)),
  )
  constants.push(RationalConstant::new(sym("Sqrt2"), Some(1.4142135623730951)))
  constants.push(RationalConstant::new(sym("Sqrt3"), Some(1.7320508075688772)))
  constants.push(RationalConstant::new(sym("Sqrt5"), Some(2.23606797749979)))
  constants.push(RationalConstant::new(sym("Log2"), Some(0.6931471805599453)))
  constants.push(RationalConstant::new(sym("Log10E"), Some(0.4342944819032518)))
  constants.push(RationalConstant::new(sym("I"), None))
  constants.push(RationalConstant::new(sym("ImaginaryUnit"), None))
  constants
}

///|
fn rational_from_base10(value : Double, tolerance : Double) -> (Int, Int)? {
  let sign = if value < 0.0 { -1 } else { 1 }
  let abs_value = abs_double(value)
  let mut denom : Int = 1
  let mut scaled = abs_value
  for _ in 0..<12 {
    let rounded = @math.round(scaled)
    if abs_double(scaled - rounded) <= tolerance {
      let numerator = rounded.to_int() * sign
      let divisor = gcd_int(abs_int(numerator), denom)
      return Some((numerator / divisor, denom / divisor))
    }
    denom = denom * 10
    scaled = abs_value * denom.to_double()
  }
  None
}

///|
fn rational_from_exact(value : Double) -> (Int, Int)? {
  if value == 0.0 {
    return Some((0, 1))
  }
  let sign = if value < 0.0 { -1 } else { 1 }
  let mut abs_value = abs_double(value)
  let mut denom : Int = 1
  for _ in 0..<52 {
    if is_integral_double(abs_value) {
      let numerator = @math.round(abs_value).to_int() * sign
      let divisor = gcd_int(abs_int(numerator), denom)
      return Some((numerator / divisor, denom / divisor))
    }
    abs_value = abs_value * 2.0
    denom = denom * 2
  }
  None
}

///|
fn double_to_rational_pair(
  value : Double,
  tolerance : Double,
  full : Bool,
  conversion : String,
) -> (Int, Int)? {
  if is_integral_double(value) {
    let rounded = @math.round(value).to_int()
    return Some((rounded, 1))
  }
  let primary = if conversion == "exact" {
    rational_from_exact(value)
  } else {
    rational_from_base10(value, tolerance)
  }
  if !full {
    return primary
  }
  let extended = rational_from_extended_search(value, tolerance, 10000)
  match (primary, extended) {
    (None, None) => None
    (Some(pair), None) => Some(pair)
    (None, Some(pair)) => Some(pair)
    (Some(primary_pair), Some(extended_pair)) => {
      let primary_error = rational_pair_error(value, primary_pair)
      let extended_error = rational_pair_error(value, extended_pair)
      let primary_valid = primary_error <= tolerance
      let extended_valid = extended_error <= tolerance
      if extended_valid && !primary_valid {
        Some(extended_pair)
      } else if extended_valid && primary_valid {
        if is_pair_simpler(extended_pair, primary_pair) {
          Some(extended_pair)
        } else {
          Some(primary_pair)
        }
      } else if primary_valid {
        Some(primary_pair)
      } else if extended_valid {
        Some(extended_pair)
      } else {
        Some(primary_pair)
      }
    }
  }
}

///|
fn rational_from_extended_search(
  value : Double,
  tolerance : Double,
  max_denominator : Int,
) -> (Int, Int)? {
  if value == 0.0 {
    return Some((0, 1))
  }
  let sign = if value < 0.0 { -1 } else { 1 }
  let abs_value = abs_double(value)
  let mut denom = 1
  while denom <= max_denominator {
    let denom_double = denom.to_double()
    let scaled = abs_value * denom_double
    let rounded = @math.round(scaled)
    let approx = rounded / denom_double
    if abs_double(abs_value - approx) <= tolerance {
      let numerator = rounded.to_int() * sign
      let divisor = gcd_int(abs_int(numerator), denom)
      return Some((numerator / divisor, denom / divisor))
    }
    denom = denom + 1
  }
  None
}

///|
fn rational_pair_error(value : Double, pair : (Int, Int)) -> Double {
  let (numerator, denominator) = pair
  let candidate = rational_pair_to_double(numerator, denominator)
  abs_double(candidate - value)
}

///|
fn rational_pair_to_double(numerator : Int, denominator : Int) -> Double {
  numerator.to_double() / denominator.to_double()
}

///|
fn is_pair_simpler(left : (Int, Int), right : (Int, Int)) -> Bool {
  let (lnum, lden) = left
  let (rnum, rden) = right
  let left_den = abs_int(lden)
  let right_den = abs_int(rden)
  if left_den != right_den {
    return left_den < right_den
  }
  let left_num = abs_int(lnum)
  let right_num = abs_int(rnum)
  if left_num != right_num {
    left_num < right_num
  } else {
    left_den <= right_den
  }
}

///|
fn build_constant_multiple(
  constant : Expr,
  numerator : Int,
  denominator : Int,
) -> Expr {
  if numerator == 0 {
    return Expr::Int(0)
  }
  let positive_num = if numerator < 0 { -numerator } else { numerator }
  let multiple = rational_expr(positive_num, denominator)
  let base = if denominator == 1 && positive_num == 1 {
    constant
  } else {
    Expr::Binary(BinaryOp::Mul, multiple, constant)
  }
  if numerator < 0 {
    Expr::Unary(UnaryOp::Neg, base)
  } else {
    base
  }
}

///|
fn build_constant_with_offset(
  constant : Expr,
  numerator : Int,
  denominator : Int,
) -> Expr {
  if numerator == 0 {
    return constant
  }
  let offset = rational_expr(
    if numerator < 0 {
      -numerator
    } else {
      numerator
    },
    denominator,
  )
  if numerator < 0 {
    Expr::Binary(BinaryOp::Sub, constant, offset)
  } else {
    Expr::Binary(BinaryOp::Add, constant, offset)
  }
}

///|
fn rationalize_double_value(
  value : Double,
  constants : Array[RationalConstant],
  tolerance : Double,
  full : Bool,
  conversion : String,
) -> Expr? {
  let mut best_expr : Expr? = None
  let mut best_complexity : Int = 0
  let mut best_error : Double = 0.0
  let len = constants.length()
  for i in 0..<len {
    let constant = constants[i]
    match constant.numeric {
      Some(approx) => {
        let error = abs_double(value - approx)
        if error <= tolerance {
          let (expr, complexity, candidate_error) = update_best_candidate(
            best_expr,
            best_complexity,
            best_error,
            constant.symbol,
            0,
            error,
          )
          best_expr = expr
          best_complexity = complexity
          best_error = candidate_error
        }
      }
      None => ()
    }
  }
  for i in 0..<len {
    let constant = constants[i]
    match constant.numeric {
      Some(approx) =>
        if abs_double(approx) <= tolerance {
          ()
        } else {
          let ratio_value = value / approx
          match
            double_to_rational_pair(ratio_value, tolerance, full, conversion) {
            Some((num, den)) =>
              if within_constant_ratio_limit(num, den) {
                let ratio_double = rational_pair_to_double(num, den)
                let candidate = approx * ratio_double
                let error = abs_double(candidate - value)
                if error <= tolerance {
                  let expr = build_constant_multiple(constant.symbol, num, den)
                  let complexity = 10 +
                    rational_complexity(abs_int(num), abs_int(den))
                  let (updated_expr, updated_complexity, updated_error) = update_best_candidate(
                    best_expr, best_complexity, best_error, expr, complexity, error,
                  )
                  best_expr = updated_expr
                  best_complexity = updated_complexity
                  best_error = updated_error
                }
              }
            None => ()
          }
        }
      None => ()
    }
  }
  for i in 0..<len {
    let constant = constants[i]
    match constant.numeric {
      Some(approx) => {
        let diff_value = value - approx
        match double_to_rational_pair(diff_value, tolerance, full, conversion) {
          Some((num, den)) =>
            if within_constant_ratio_limit(num, den) {
              let offset_double = rational_pair_to_double(num, den)
              let candidate = approx + offset_double
              let error = abs_double(candidate - value)
              if error <= tolerance {
                let expr = build_constant_with_offset(constant.symbol, num, den)
                let complexity = 20 +
                  rational_complexity(abs_int(num), abs_int(den))
                let (updated_expr, updated_complexity, updated_error) = update_best_candidate(
                  best_expr, best_complexity, best_error, expr, complexity, error,
                )
                best_expr = updated_expr
                best_complexity = updated_complexity
                best_error = updated_error
              }
            }
          None => ()
        }
      }
      None => ()
    }
  }
  match double_to_rational_pair(value, tolerance, full, conversion) {
    Some((num, den)) => {
      let error = rational_pair_error(value, (num, den))
      if error <= tolerance {
        let expr = rational_expr(num, den)
        let complexity = 5 + rational_complexity(abs_int(num), abs_int(den))
        let (updated_expr, updated_complexity, updated_error) = update_best_candidate(
          best_expr, best_complexity, best_error, expr, complexity, error,
        )
        best_expr = updated_expr
        best_complexity = updated_complexity
        best_error = updated_error
      }
    }
    None => ()
  }
  best_expr
}

///|
fn rational_expr(numerator : Int, denominator : Int) -> Expr {
  if denominator == 1 {
    Expr::Int(numerator)
  } else {
    Expr::Binary(BinaryOp::Div, Expr::Int(numerator), Expr::Int(denominator))
  }
}

///|
fn abs_int(value : Int) -> Int {
  if value < 0 {
    -value
  } else {
    value
  }
}

///|
fn within_constant_ratio_limit(numerator : Int, denominator : Int) -> Bool {
  let max_value = 512
  abs_int(denominator) <= max_value && abs_int(numerator) <= max_value
}

///|
fn update_best_candidate(
  best_expr : Expr?,
  best_complexity : Int,
  best_error : Double,
  candidate_expr : Expr,
  candidate_complexity : Int,
  candidate_error : Double,
) -> (Expr?, Int, Double) {
  match best_expr {
    Some(existing) => {
      let better = if candidate_complexity < best_complexity {
        true
      } else if candidate_complexity == best_complexity {
        candidate_error < best_error
      } else {
        false
      }
      if better {
        (Some(candidate_expr), candidate_complexity, candidate_error)
      } else {
        (Some(existing), best_complexity, best_error)
      }
    }
    None => (Some(candidate_expr), candidate_complexity, candidate_error)
  }
}

///|
fn rational_complexity(numerator : Int, denominator : Int) -> Int {
  abs_int(numerator) + abs_int(denominator)
}

///|
fn gcd_int(a : Int, b : Int) -> Int {
  let mut x = abs_int(a)
  let mut y = abs_int(b)
  while y != 0 {
    let temp = x % y
    x = y
    y = temp
  }
  if x == 0 {
    1
  } else {
    x
  }
}
