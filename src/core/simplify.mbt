///|
pub fn simplify(
  expr : Expr,
  ratio? : Double = 1.7,
  measure? : (Expr) -> Double = count_ops,
  rational? : Bool = false,
  inverse? : Bool = false,
  doit? : Bool = true,
) -> Expr {
  let preprocessed = if inverse { inverse_cancellation(expr) } else { expr }
  let simplified_once = simplify_reduce(preprocessed)
  let rationalized = if rational {
    rationalize_expr(simplified_once)
  } else {
    simplified_once
  }
  let candidate = if doit {
    simplify_reduce(rationalized)
  } else {
    rationalized
  }
  let original_measure = measure(expr)
  let candidate_measure = measure(candidate)
  if should_preserve_original(original_measure, candidate_measure, ratio) {
    expr
  } else {
    candidate
  }
}

///|
/// 自带评价式子复杂程度函数
pub fn count_ops(expr : Expr) -> Double {
  match expr {
    Expr::Int(_) => 0.0
    Expr::Double(_) => 0.0
    Expr::Symbol(_) => 0.0
    Expr::Unary(_, inner) => 1 + count_ops(inner)
    Expr::Binary(_, left, right) => 1 + count_ops(left) + count_ops(right)
    Expr::FunctionCall(_, args) => 1 + count_ops_args(args) // 特殊函数
  }
}

///|
/// 特殊函数情况
fn count_ops_args(args : Array[Expr]) -> Double {
  args.fold(init=0, (acc : Double, item : Expr) => acc + count_ops(item))
}

///|
/// 看看是保存之前的还是用新的替换
fn should_preserve_original(
  original : Double,
  candidate : Double,
  ratio : Double,
) -> Bool {
  if ratio <= 0.0 {
    candidate > 0.0
  } else if original == 0.0 {
    candidate > 0.0
  } else {
    let limit = original * ratio
    candidate > limit
  }
}

///|
/// 反函数消去
fn inverse_cancellation(expr : Expr) -> Expr {
  match expr {
    Expr::Unary(op, inner) => {
      let inner_simplified = inverse_cancellation(inner)
      match inner_simplified {
        Expr::Unary(inner_op, inner_arg) =>
          if unary_inverse_pair(op, inner_op) {
            inverse_cancellation(inner_arg)
          } else {
            Expr::Unary(op, Expr::Unary(inner_op, inner_arg))
          }
        other => Expr::Unary(op, other)
      }
    }
    Expr::Binary(op, left, right) =>
      Expr::Binary(op, inverse_cancellation(left), inverse_cancellation(right))
    Expr::FunctionCall(name, args) => {
      let transformed = args.map(arg => inverse_cancellation(arg))
      Expr::FunctionCall(name, transformed)
    }
    other => other
  }
}

///|
/// 实现结构有理化。
pub fn rationalize_expr(
  expr : Expr,
  constants? : Array[RationalConstant] = default_rational_constants(),
  tolerance? : Double = 1.0e-10,
  full? : Bool = false,
  rational? : Bool = true,
  rational_conversion? : String = "base10",
) -> Expr {
  if !rational {
    return expr
  }
  match expr {
    Expr::Double(value) =>
      match
        rationalize_double_value(
          value, constants, tolerance, full, rational_conversion,
        ) {
        Some(expr) => expr
        None => Expr::Double(value)
      }
    Expr::Unary(op, inner) =>
      Expr::Unary(
        op,
        rationalize_expr(
          inner,
          constants~,
          tolerance~,
          full~,
          rational~,
          rational_conversion~,
        ),
      )
    Expr::Binary(op, left, right) =>
      Expr::Binary(
        op,
        rationalize_expr(
          left,
          constants~,
          tolerance~,
          full~,
          rational~,
          rational_conversion~,
        ),
        rationalize_expr(
          right,
          constants~,
          tolerance~,
          full~,
          rational~,
          rational_conversion~,
        ),
      )
    Expr::FunctionCall(name, args) => {
      let transformed = args.map(arg => rationalize_expr(
        arg,
        constants~,
        tolerance~,
        full~,
        rational~,
        rational_conversion~,
      ))
      Expr::FunctionCall(name, transformed)
    }
    other => other
  }
}

///|
fn simplify_reduce(expr : Expr) -> Expr {
  match expr {
    Expr::Unary(UnaryOp::Neg, inner) => {
      let simplified_inner = simplify_reduce(inner)
      match simplified_inner {
        Expr::Int(value) => Expr::Int(-value)
        Expr::Double(value) => Expr::Double(-value)
        other => Expr::Unary(UnaryOp::Neg, other)
      }
    }
    Expr::Unary(op, inner) => Expr::Unary(op, simplify_reduce(inner))
    Expr::Binary(BinaryOp::Add, left, right) => simplify_add(left, right)
    Expr::Binary(BinaryOp::Sub, left, right) => simplify_sub(left, right)
    Expr::Binary(BinaryOp::Mul, left, right) => simplify_mul(left, right)
    Expr::Binary(BinaryOp::Div, left, right) => simplify_div(left, right)
    Expr::Binary(BinaryOp::Pow, base, exponent) => simplify_pow(base, exponent)
    Expr::FunctionCall(name, args) => {
      let simplified_args = args.map(arg => simplify_reduce(arg))
      Expr::FunctionCall(name, simplified_args)
    }
    other => other
  }
}

///|
/// 针对于加法处理（合并同类项）
fn simplify_add(left : Expr, right : Expr) -> Expr {
  let left_s = simplify_reduce(left)
  let right_s = simplify_reduce(right)
  let (left_zero, left_clean) = simplify_is_zero_literal(left_s)
  let (right_zero, right_clean) = simplify_is_zero_literal(right_s)
  if left_zero {
    right_clean
  } else if right_zero {
    left_clean
  } else {
    let mut terms = Array::new()
    terms = append_add_terms(left_clean, terms) // 拍平所有加法
    terms = append_add_terms(right_clean, terms)
    combine_polynomial_terms(terms)
  }
}

///|
/// 一串加法拍平，拆出所有的加法
fn append_add_terms(expr : Expr, terms : Array[Expr]) -> Array[Expr] {
  match expr {
    Expr::Binary(BinaryOp::Add, left, right) => {
      let collected = append_add_terms(left, terms)
      append_add_terms(right, collected)
    }
    other => {
      let updated = terms
      updated.push(other)
      updated
    }
  }
}

///|
fn combine_polynomial_terms(terms : Array[Expr]) -> Expr {
  let monomials = Array::new()
  let coefficients = Array::new()
  for term in terms {
    let (coeff, factors) = extract_polynomial_term(term) // 分解为系数+因子
    let normalized_factors = normalize_factors(factors)
    let monomial = build_monomial_from_factors(normalized_factors)
    let index = find_monomial_index(monomials, monomial)
    if index < 0 {
      monomials.push(monomial)
      coefficients.push(coeff)
    } else {
      let existing = coefficients[index]
      coefficients[index] = add_coefficients(existing, coeff)
    }
  }
  let mut result : Expr? = None
  let len = monomials.length()
  for i in 0..<len {
    let coeff = coefficients[i]
    let monomial = monomials[i]
    if is_zero_coefficient(coeff) {
      continue
    }
    let term_expr = term_from_parts(coeff, monomial)
    let (is_zero_term, _) = simplify_is_zero_literal(term_expr)
    if is_zero_term {
      continue
    }
    match result {
      Some(current) =>
        result = Some(Expr::Binary(BinaryOp::Add, current, term_expr))
      None => result = Some(term_expr)
    }
  }
  match result {
    Some(expr) => expr
    None => Expr::Int(0)
  }
}

///|
/// 输入表达式输出系数和因子数组，以供合并同类项
fn extract_polynomial_term(expr : Expr) -> (Expr, Array[Expr]) {
  match expr {
    Expr::Binary(BinaryOp::Mul, left, right) => {
      let (left_coeff, left_factors) = extract_polynomial_term(left)
      let (right_coeff, right_factors) = extract_polynomial_term(right)
      let combined_coeff = multiply_coefficients(left_coeff, right_coeff)
      let merged_factors = merge_factors(left_factors, right_factors)
      (combined_coeff, merged_factors)
    }
    Expr::Unary(UnaryOp::Neg, inner) => {
      let (inner_coeff, inner_factors) = extract_polynomial_term(inner)
      let negated_coeff = multiply_coefficients(Expr::Int(-1), inner_coeff)
      (negated_coeff, inner_factors)
    }
    Expr::Int(value) => {
      let factors = Array::new()
      (Expr::Int(value), factors)
    }
    Expr::Double(value) => {
      let factors = Array::new()
      (Expr::Double(value), factors)
    }
    other => {
      let factors = Array::new(capacity=1)
      factors.push(other)
      (Expr::Int(1), factors)
    }
  }
}

///|
/// 合并拆解因子列表函数
fn merge_factors(left : Array[Expr], right : Array[Expr]) -> Array[Expr] {
  let merged = Array::new(capacity=left.length() + right.length())
  for item in left {
    merged.push(item)
  }
  for item in right {
    merged.push(item)
  }
  merged
}

///|
/// 让传入的因子顺序均相同，使用冒泡排序
fn normalize_factors(factors : Array[Expr]) -> Array[Expr] {
  let normalized = Array::new(capacity=factors.length())
  for factor in factors {
    normalized.push(factor)
  }
  let len = normalized.length()
  for i = 0; i < len; i = i + 1 {
    for j = i + 1; j < len; j = j + 1 {
      let sig_i = normalized[i].to_string()
      let sig_j = normalized[j].to_string()
      if sig_j < sig_i {
        let temp_expr = normalized[i]
        normalized[i] = normalized[j]
        normalized[j] = temp_expr
      }
    }
  }
  normalized
}

///|
/// 将拆开的系数乘法合并出来
fn build_monomial_from_factors(factors : Array[Expr]) -> Expr {
  let len = factors.length()
  if len == 0 {
    Expr::Int(1)
  } else if len == 1 {
    factors[0]
  } else {
    let mut result = factors[0]
    for i in 1..<len {
      result = Expr::Binary(BinaryOp::Mul, result, factors[i])
    }
    result
  }
}

///|
/// 查找并返回目标单项式的位置
fn find_monomial_index(monomials : Array[Expr], target : Expr) -> Int {
  let len = monomials.length()
  for i in 0..<len {
    if monomials[i] == target {
      return i
    }
  }
  -1
}

///|
/// 系数加法穷举
fn add_coefficients(lhs : Expr, rhs : Expr) -> Expr {
  match (lhs, rhs) {
    (Expr::Int(left_val), Expr::Int(right_val)) =>
      Expr::Int(left_val + right_val)
    (Expr::Double(left_val), Expr::Double(right_val)) =>
      Expr::Double(left_val + right_val)
    (Expr::Int(left_val), Expr::Double(right_val)) =>
      Expr::Double(left_val.to_double() + right_val)
    (Expr::Double(left_val), Expr::Int(right_val)) =>
      Expr::Double(left_val + right_val.to_double())
    (Expr::Int(0), other) => other
    (other, Expr::Int(0)) => other
    (Expr::Double(0.0), other) => other
    (other, Expr::Double(0.0)) => other
    (left_expr, right_expr) =>
      Expr::Binary(BinaryOp::Add, left_expr, right_expr)
  }
}

///|
/// 系数乘法穷举
fn multiply_coefficients(lhs : Expr, rhs : Expr) -> Expr {
  match (lhs, rhs) {
    (Expr::Int(left_val), Expr::Int(right_val)) =>
      Expr::Int(left_val * right_val)
    (Expr::Double(left_val), Expr::Double(right_val)) =>
      Expr::Double(left_val * right_val)
    (Expr::Int(left_val), Expr::Double(right_val)) =>
      Expr::Double(left_val.to_double() * right_val)
    (Expr::Double(left_val), Expr::Int(right_val)) =>
      Expr::Double(left_val * right_val.to_double())
    (Expr::Int(1), other) => other
    (other, Expr::Int(1)) => other
    (Expr::Double(1.0), other) => other
    (other, Expr::Double(1.0)) => other
    (left_expr, right_expr) =>
      Expr::Binary(BinaryOp::Mul, left_expr, right_expr)
  }
}

///|
fn term_from_parts(coeff : Expr, monomial : Expr) -> Expr {
  let (coeff_zero, coeff_clean) = simplify_is_zero_literal(coeff)
  if coeff_zero {
    return Expr::Int(0)
  }
  let (coeff_one, coeff_value) = simplify_is_one_literal(coeff_clean)
  if monomial == Expr::Int(1) {
    coeff_value
  } else if coeff_one {
    monomial
  } else if simplify_is_minus_one_literal(coeff_value) {
    Expr::Unary(UnaryOp::Neg, monomial)
  } else {
    Expr::Binary(BinaryOp::Mul, coeff_value, monomial)
  }
}

///|
fn is_zero_coefficient(expr : Expr) -> Bool {
  let (is_zero, _) = simplify_is_zero_literal(expr)
  is_zero
}

///|
fn simplify_is_minus_one_literal(expr : Expr) -> Bool {
  match expr {
    Expr::Int(value) => value == -1
    Expr::Double(value) => value == -1.0
    _ => false
  }
}

///|
/// sympy中不使用这个sub方法，a-b转化成a+(-1)*b
fn simplify_sub(left : Expr, right : Expr) -> Expr {
  let left_s = simplify_reduce(left)
  let right_s = simplify_reduce(right)
  let (right_zero, right_clean) = simplify_is_zero_literal(right_s)
  if right_zero {
    left_s
  } else {
    match (left_s, right_clean) {
      (Expr::Int(lhs), Expr::Int(rhs)) => Expr::Int(lhs - rhs)
      (Expr::Double(lhs), Expr::Double(rhs)) => Expr::Double(lhs - rhs)
      (lhs, rhs) => Expr::Binary(BinaryOp::Sub, lhs, rhs)
    }
  }
}

///|
/// 针对乘法处理（合并系数，合并幂）
fn simplify_mul(left : Expr, right : Expr) -> Expr {
  let left_s = simplify_reduce(left)
  let right_s = simplify_reduce(right)
  let (left_zero, left_clean) = simplify_is_zero_literal(left_s)
  let (right_zero, right_clean) = simplify_is_zero_literal(right_s)
  if left_zero || right_zero {
    return Expr::Int(0)
  }
  let mut factors = Array::new()
  factors = collect_mul_factors(left_clean, factors)
  factors = collect_mul_factors(right_clean, factors)
  let mut coeff_int = 1
  let mut has_int = false
  let mut coeff_double : Double? = None
  let mut symbol_counts : Array[(Expr, Int)] = Array::new()
  let other_factors : Array[Expr] = Array::new()
  let mut is_negative = false
  for factor in factors {
    match factor {
      Expr::Int(value) => {
        if value == 0 {
          return Expr::Int(0)
        }
        coeff_int = coeff_int * value
        has_int = true
      }
      Expr::Double(value) => {
        if value == 0.0 {
          return Expr::Double(0.0)
        }
        coeff_double = match coeff_double {
          Some(current) => Some(current * value)
          None => Some(value)
        }
      }
      Expr::Binary(BinaryOp::Pow, Expr::Symbol(symbol), Expr::Int(exp)) => {
        let base = Expr::Symbol(symbol)
        symbol_counts = add_symbol_power(symbol_counts, base, exp)
      }
      Expr::Symbol(symbol) => {
        let base = Expr::Symbol(symbol)
        symbol_counts = add_symbol_power(symbol_counts, base, 1)
      }
      other => other_factors.push(other)
    }
  }
  if has_int && coeff_int == 0 {
    return Expr::Int(0)
  }
  let final_factors = Array::new()
  match coeff_double {
    Some(value) => {
      let combined = if has_int { value * coeff_int.to_double() } else { value }
      if combined == 0.0 {
        return Expr::Double(0.0)
      }
      let magnitude = if combined < 0.0 {
        is_negative = !is_negative
        -combined
      } else {
        combined
      }
      if magnitude != 1.0 {
        final_factors.push(Expr::Double(magnitude))
      }
      has_int = false
      coeff_int = 1
    }
    None => ()
  }
  if has_int {
    let magnitude = if coeff_int < 0 {
      is_negative = !is_negative
      -coeff_int
    } else {
      coeff_int
    }
    if magnitude != 1 {
      final_factors.push(Expr::Int(magnitude))
    }
  }
  for entry in symbol_counts {
    let (base, power) = entry
    if power == 0 {
      continue
    }
    if power == 1 {
      final_factors.push(base)
    } else {
      final_factors.push(Expr::Binary(BinaryOp::Pow, base, Expr::Int(power)))
    }
  }
  for factor in other_factors {
    final_factors.push(factor)
  }
  let len = final_factors.length()
  let base_expr = if len == 0 {
    Expr::Int(1)
  } else if len == 1 {
    final_factors[0]
  } else {
    build_monomial_from_factors(final_factors)
  }
  if is_negative {
    match base_expr {
      Expr::Int(value) => Expr::Int(-value)
      Expr::Double(value) => Expr::Double(-value)
      Expr::Unary(UnaryOp::Neg, inner) => inner
      Expr::Binary(BinaryOp::Mul, Expr::Int(-1), rest) => rest
      Expr::Binary(BinaryOp::Mul, rest, Expr::Int(-1)) => rest
      other => Expr::Unary(UnaryOp::Neg, other)
    }
  } else {
    base_expr
  }
}

///|
/// 收集乘法因子
fn collect_mul_factors(expr : Expr, factors : Array[Expr]) -> Array[Expr] {
  match expr {
    Expr::Binary(BinaryOp::Mul, left, right) => {
      let collected = collect_mul_factors(left, factors)
      collect_mul_factors(right, collected)
    }
    Expr::Unary(UnaryOp::Neg, inner) => {
      let updated = factors
      updated.push(Expr::Int(-1))
      collect_mul_factors(inner, updated)
    }
    other => {
      let updated = factors
      updated.push(other)
      updated
    }
  }
}

///|
fn pow_product_with_int(
  coeff : Expr,
  factors : Array[Expr],
  exponent : Int,
) -> Expr {
  if exponent == 0 {
    return Expr::Int(1)
  }
  let coeff_pow = simplify_pow(coeff, Expr::Int(exponent))
  let len = factors.length()
  let mut result = coeff_pow
  for i in 0..<len {
    let factor_pow = simplify_pow(factors[i], Expr::Int(exponent))
    result = simplify_mul(result, factor_pow)
  }
  result
}

///|
fn pow_product_with_double(
  coeff : Expr,
  factors : Array[Expr],
  exponent_expr : Expr,
  exponent_value : Double,
) -> Expr {
  if exponent_value == 0.0 {
    return Expr::Int(1)
  }
  let coeff_value = match coeff {
    Expr::Int(v) => v.to_double()
    Expr::Double(v) => v
    _ => 1.0
  }
  let coeff_pow = @math.pow(coeff_value, exponent_value)
  let coeff_expr = if is_integral_double(coeff_pow) {
    Expr::Int(@math.round(coeff_pow).to_int())
  } else {
    Expr::Double(coeff_pow)
  }
  let len = factors.length()
  let mut result = coeff_expr
  for i in 0..<len {
    let factor_pow = simplify_pow(factors[i], exponent_expr)
    result = simplify_mul(result, factor_pow)
  }
  result
}

///|
fn abs_double(value : Double) -> Double {
  if value < 0.0 {
    -value
  } else {
    value
  }
}

///|
fn is_integral_double(value : Double) -> Bool {
  let rounded = @math.round(value)
  abs_double(value - rounded) <= 1.0e-10
}

///|
/// 合并相同符号的幂
fn add_symbol_power(
  symbol_counts : Array[(Expr, Int)],
  base : Expr,
  delta : Int,
) -> Array[(Expr, Int)] {
  let len = symbol_counts.length()
  for i in 0..<len {
    let (existing_base, existing_power) = symbol_counts[i]
    if existing_base == base {
      symbol_counts[i] = (existing_base, existing_power + delta)
      return symbol_counts
    } else {
      symbol_counts[i] = (existing_base, existing_power)
    }
  }
  symbol_counts.push((base, delta))
  symbol_counts
}

///|
fn int_pow(base : Int, exponent : Int) -> Int {
  if exponent <= 0 {
    return 1
  }
  let mut result = 1
  let mut e = exponent
  let mut b = base
  while e > 0 {
    if e % 2 != 0 {
      result = result * b
    }
    e = e / 2
    if e > 0 {
      b = b * b
    }
  }
  result
}

///|
fn simplify_div(left : Expr, right : Expr) -> Expr {
  let left_s = simplify_reduce(left)
  let right_s = simplify_reduce(right)
  let (right_one, right_clean) = simplify_is_one_literal(right_s)
  if right_one {
    left_s
  } else {
    match (left_s, right_clean) {
      (Expr::Int(lhs), Expr::Int(rhs)) =>
        if rhs != 0 && lhs % rhs == 0 {
          Expr::Int(lhs / rhs)
        } else {
          Expr::Binary(BinaryOp::Div, Expr::Int(lhs), Expr::Int(rhs))
        }
      (Expr::Double(lhs), Expr::Double(rhs)) => Expr::Double(lhs / rhs)
      (lhs, rhs) => Expr::Binary(BinaryOp::Div, lhs, rhs)
    }
  }
}

///|
fn simplify_pow(base : Expr, exponent : Expr) -> Expr {
  let base_s = simplify_reduce(base)
  let exponent_s = simplify_reduce(exponent)
  let (exp_zero, exp_clean) = simplify_is_zero_literal(exponent_s)
  if exp_zero {
    return Expr::Int(1)
  }
  let (exp_one, exp_value) = simplify_is_one_literal(exp_clean)
  if exp_one {
    return base_s
  }
  let exp_int = match exp_value {
    Expr::Int(value) => Some(value)
    _ => None
  }
  match base_s {
    Expr::Int(value) =>
      match exp_int {
        Some(exp_val) =>
          if exp_val >= 0 {
            if value == 0 {
              return Expr::Int(0)
            }
            if value == 1 {
              return Expr::Int(1)
            }
            if value == -1 {
              if exp_val % 2 == 0 {
                return Expr::Int(1)
              } else {
                return Expr::Int(-1)
              }
            }
            return Expr::Int(int_pow(value, exp_val))
          } else {
            let abs_exp = -exp_val
            if value == 0 {
              return Expr::Binary(BinaryOp::Pow, Expr::Int(0), exp_value)
            }
            if value == 1 {
              return Expr::Int(1)
            }
            if value == -1 {
              if abs_exp % 2 == 0 {
                return Expr::Int(1)
              } else {
                return Expr::Int(-1)
              }
            }
            let positive = simplify_pow(Expr::Int(value), Expr::Int(abs_exp))
            return simplify_div(Expr::Int(1), positive)
          }
        None => {
          if value == 0 {
            return Expr::Int(0)
          }
          if value == 1 {
            return Expr::Int(1)
          }
          if value == -1 {
            return Expr::Binary(BinaryOp::Pow, base_s, exp_value)
          }
        }
      }
    Expr::Double(value) =>
      match exp_int {
        Some(exp_val) => {
          if value == 0.0 {
            if exp_val < 0 {
              return Expr::Binary(BinaryOp::Pow, base_s, exp_value)
            } else {
              return Expr::Double(0.0)
            }
          }
          if value == 1.0 {
            return Expr::Double(1.0)
          }
          if value == -1.0 {
            if exp_val % 2 == 0 {
              return Expr::Double(1.0)
            } else {
              return Expr::Double(-1.0)
            }
          }
          let combined = @math.pow(value, exp_val.to_double())
          return Expr::Double(combined)
        }
        None =>
          match exp_value {
            Expr::Double(exp_double) => {
              if value == 0.0 && exp_double < 0.0 {
                return Expr::Binary(BinaryOp::Pow, base_s, exp_value)
              }
              if value == 1.0 {
                return Expr::Double(1.0)
              }
              if value == -1.0 {
                return Expr::Binary(BinaryOp::Pow, base_s, exp_value)
              }
              let combined = @math.pow(value, exp_double)
              return Expr::Double(combined)
            }
            _ => {
              if value == 0.0 {
                return Expr::Double(0.0)
              }
              if value == 1.0 {
                return Expr::Double(1.0)
              }
              if value == -1.0 {
                return Expr::Binary(BinaryOp::Pow, base_s, exp_value)
              }
            }
          }
      }
    Expr::Binary(BinaryOp::Mul, _, _) =>
      match exp_int {
        Some(exp_val) => {
          let (coeff, factors) = extract_polynomial_term(base_s)
          match coeff {
            Expr::Int(_) | Expr::Double(_) => {
              let abs_exp = if exp_val < 0 { -exp_val } else { exp_val }
              let positive = pow_product_with_int(coeff, factors, abs_exp)
              if exp_val >= 0 {
                return positive
              } else {
                return simplify_div(Expr::Int(1), positive)
              }
            }
            _ => ()
          }
        }
        None =>
          match exp_value {
            Expr::Double(exp_double) => {
              let (coeff, factors) = extract_polynomial_term(base_s)
              match coeff {
                Expr::Int(coeff_int) =>
                  if coeff_int < 0 && !is_integral_double(exp_double) {
                    ()
                  } else {
                    let positive_exp = if exp_double < 0.0 {
                      -exp_double
                    } else {
                      exp_double
                    }
                    let exponent_expr = Expr::Double(positive_exp)
                    let positive = pow_product_with_double(
                      Expr::Int(coeff_int),
                      factors,
                      exponent_expr,
                      positive_exp,
                    )
                    if exp_double >= 0.0 {
                      return positive
                    } else {
                      return simplify_div(Expr::Int(1), positive)
                    }
                  }
                Expr::Double(coeff_double) =>
                  if coeff_double < 0.0 && !is_integral_double(exp_double) {
                    ()
                  } else {
                    let positive_exp = if exp_double < 0.0 {
                      -exp_double
                    } else {
                      exp_double
                    }
                    let exponent_expr = Expr::Double(positive_exp)
                    let positive = pow_product_with_double(
                      Expr::Double(coeff_double),
                      factors,
                      exponent_expr,
                      positive_exp,
                    )
                    if exp_double >= 0.0 {
                      return positive
                    } else {
                      return simplify_div(Expr::Int(1), positive)
                    }
                  }
                _ => ()
              }
            }
            _ => ()
          }
      }
    Expr::Binary(BinaryOp::Pow, inner_base, inner_exp) => {
      let combined_exp = simplify_mul(inner_exp, exp_value)
      return simplify_pow(inner_base, combined_exp)
    }
    _ => ()
  }
  match exp_int {
    Some(exp_val) =>
      if exp_val < 0 {
        let positive_exp = Expr::Int(-exp_val)
        let positive_pow = simplify_pow(base_s, positive_exp)
        simplify_div(Expr::Int(1), positive_pow)
      } else {
        Expr::Binary(BinaryOp::Pow, base_s, exp_value)
      }
    None => Expr::Binary(BinaryOp::Pow, base_s, exp_value)
  }
}

///|
fn simplify_is_zero_literal(expr : Expr) -> (Bool, Expr) {
  match expr {
    Expr::Int(value) =>
      if value == 0 {
        (true, Expr::Int(0))
      } else {
        (false, Expr::Int(value))
      }
    Expr::Double(value) =>
      if value == 0.0 {
        (true, Expr::Double(0.0))
      } else {
        (false, Expr::Double(value))
      }
    other => (false, other)
  }
}

///|
fn simplify_is_one_literal(expr : Expr) -> (Bool, Expr) {
  match expr {
    Expr::Int(value) =>
      if value == 1 {
        (true, Expr::Int(1))
      } else {
        (false, Expr::Int(value))
      }
    Expr::Double(value) =>
      if value == 1.0 {
        (true, Expr::Double(1.0))
      } else {
        (false, Expr::Double(value))
      }
    other => (false, other)
  }
}

///|
fn unary_inverse_pair(outer : UnaryOp, inner : UnaryOp) -> Bool {
  match (outer, inner) {
    (UnaryOp::Neg, UnaryOp::Neg)
    | (UnaryOp::Sin, UnaryOp::Asin)
    | (UnaryOp::Asin, UnaryOp::Sin)
    | (UnaryOp::Cos, UnaryOp::Acos)
    | (UnaryOp::Acos, UnaryOp::Cos)
    | (UnaryOp::Tan, UnaryOp::Atan)
    | (UnaryOp::Atan, UnaryOp::Tan)
    | (UnaryOp::Sinh, UnaryOp::Asinh)
    | (UnaryOp::Asinh, UnaryOp::Sinh)
    | (UnaryOp::Cosh, UnaryOp::Acosh)
    | (UnaryOp::Acosh, UnaryOp::Cosh)
    | (UnaryOp::Tanh, UnaryOp::Atanh)
    | (UnaryOp::Atanh, UnaryOp::Tanh)
    | (UnaryOp::Exp, UnaryOp::Log)
    | (UnaryOp::Log, UnaryOp::Exp) => true
    _ => false
  }
}
