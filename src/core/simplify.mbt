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
/// 仅仅实现结构遍历，本意是实现结构有理化。
fn rationalize_expr(expr : Expr) -> Expr {
  match expr {
    Expr::Unary(op, inner) => Expr::Unary(op, rationalize_expr(inner))
    Expr::Binary(op, left, right) =>
      Expr::Binary(op, rationalize_expr(left), rationalize_expr(right))
    Expr::FunctionCall(name, args) => {
      let transformed = args.map(arg => rationalize_expr(arg))
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
fn simplify_mul(left : Expr, right : Expr) -> Expr {
  let left_s = simplify_reduce(left)
  let right_s = simplify_reduce(right)
  let (left_zero, left_clean) = simplify_is_zero_literal(left_s)
  let (right_zero, right_clean) = simplify_is_zero_literal(right_s)
  if left_zero || right_zero {
    Expr::Int(0)
  } else {
    let (left_one, left_value) = simplify_is_one_literal(left_clean)
    if left_one {
      right_clean
    } else {
      let (right_one, right_value) = simplify_is_one_literal(right_clean)
      if right_one {
        left_value
      } else {
        match (left_value, right_value) {
          (Expr::Int(lhs), Expr::Int(rhs)) => Expr::Int(lhs * rhs)
          (Expr::Double(lhs), Expr::Double(rhs)) => Expr::Double(lhs * rhs)
          (lhs, rhs) => Expr::Binary(BinaryOp::Mul, lhs, rhs)
        }
      }
    }
  }
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
    Expr::Int(1)
  } else {
    let (exp_one, exp_value) = simplify_is_one_literal(exp_clean)
    if exp_one {
      base_s
    } else {
      Expr::Binary(BinaryOp::Pow, base_s, exp_value)
    }
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
