///|
pub fn solve_linear_equation(
  lhs : Expr,
  rhs : Expr,
  variable_name : String,
) -> Expr {
  let equation = simplify(sub(lhs, rhs))
  let coeff = simplify(coefficient_of(equation, variable_name))
  let constant = simplify(coefficient_of(equation, variable_name, degree=0))
  if contains_coeff_placeholder(coeff) || contains_coeff_placeholder(constant) {
    return solve_linear_fallback(variable_name, lhs, rhs)
  }
  if has_non_linear_terms(equation, variable_name) {
    return solve_linear_fallback(variable_name, lhs, rhs)
  }
  if is_zero_literal_linear(coeff) {
    match constant {
      Expr::Int(value) =>
        if value == 0 {
          return solve_linear_fallback(variable_name, lhs, rhs)
        } else {
          return no_solution_expr()
        }
      Expr::Double(value) =>
        if value == 0.0 {
          return solve_linear_fallback(variable_name, lhs, rhs)
        } else {
          return no_solution_expr()
        }
      _ => return solve_linear_fallback(variable_name, lhs, rhs)
    }
  }
  let neg_constant = simplify(Expr::Unary(UnaryOp::Neg, constant))
  build_fraction(neg_constant, coeff)
}

///|
pub fn solve_linear_system(
  lhs1 : Expr,
  rhs1 : Expr,
  lhs2 : Expr,
  rhs2 : Expr,
  var_x : String,
  var_y : String,
) -> (Expr, Expr) {
  let eq1 = simplify(sub(lhs1, rhs1))
  let eq2 = simplify(sub(lhs2, rhs2))
  let a1 = simplify(coefficient_of(eq1, var_x))
  let b1 = simplify(coefficient_of(eq1, var_y))
  let c1 = constant_term(eq1, var_x, var_y)
  let a2 = simplify(coefficient_of(eq2, var_x))
  let b2 = simplify(coefficient_of(eq2, var_y))
  let c2 = constant_term(eq2, var_x, var_y)
  if coefficients_need_fallback([a1, b1, c1, a2, b2, c2]) {
    return solve_linear_system_fallback(lhs1, rhs1, lhs2, rhs2, var_x, var_y)
  }
  let det = simplify(
    sub(
      Expr::Binary(BinaryOp::Mul, a1, b2),
      Expr::Binary(BinaryOp::Mul, a2, b1),
    ),
  )
  if is_zero_literal_linear(det) {
    return solve_linear_system_fallback(lhs1, rhs1, lhs2, rhs2, var_x, var_y)
  }
  let rhs_vec1 = simplify(Expr::Unary(UnaryOp::Neg, c1))
  let rhs_vec2 = simplify(Expr::Unary(UnaryOp::Neg, c2))
  let numerator_x = simplify(
    sub(
      Expr::Binary(BinaryOp::Mul, rhs_vec1, b2),
      Expr::Binary(BinaryOp::Mul, b1, rhs_vec2),
    ),
  )
  let numerator_y = simplify(
    sub(
      Expr::Binary(BinaryOp::Mul, a1, rhs_vec2),
      Expr::Binary(BinaryOp::Mul, rhs_vec1, a2),
    ),
  )
  let x_solution = build_fraction(numerator_x, det)
  let y_solution = build_fraction(numerator_y, det)
  (x_solution, y_solution)
}

///|
pub fn solve_linear_system_n(
  equations : Array[(Expr, Expr)],
  variable_names : Array[String],
) -> Array[Expr] {
  let var_count = variable_names.length()
  if var_count == 0 || equations.length() != var_count {
    return solve_linear_system_n_fallback(variable_names, equations)
  }
  let coeff_rows = Array::new(capacity=var_count)
  let constants = Array::new(capacity=var_count)
  for idx in 0..<equations.length() {
    let (lhs, rhs) = equations[idx]
    let normalized = simplify(sub(lhs, rhs))
    let coeff_row = Array::new(capacity=var_count)
    for var_name in variable_names {
      let coeff = simplify(coefficient_of(normalized, var_name))
      coeff_row.push(coeff)
    }
    let constant = simplify(constant_term_multi(normalized, variable_names))
    coeff_rows.push(coeff_row)
    constants.push(constant)
  }
  if coefficients_need_matrix_fallback(coeff_rows, constants) {
    return solve_linear_system_n_fallback(variable_names, equations)
  }
  let coeff_numeric = Array::new(capacity=var_count)
  for row in coeff_rows {
    let numeric_row = Array::new(capacity=var_count)
    for coeff in row {
      match literal_to_double(coeff) {
        Some(value) => numeric_row.push(value)
        None => return solve_linear_system_n_fallback(variable_names, equations)
      }
    }
    coeff_numeric.push(numeric_row)
  }
  let rhs_values = Array::new(capacity=var_count)
  for constant in constants {
    match literal_to_double(constant) {
      Some(value) => rhs_values.push(-value)
      None => return solve_linear_system_n_fallback(variable_names, equations)
    }
  }
  match solve_numeric_linear_system(coeff_numeric, rhs_values) {
    LinearSystemSolveResult::Unique(values) => {
      let solutions = Array::new(capacity=var_count)
      for value in values {
        solutions.push(double_to_expr(value))
      }
      solutions
    }
    LinearSystemSolveResult::NoSolution =>
      build_no_solution_array(variable_names.length())
    LinearSystemSolveResult::Underdetermined =>
      solve_linear_system_n_fallback(variable_names, equations)
  }
}

///|
fn coefficients_need_fallback(values : Array[Expr]) -> Bool {
  for value in values {
    if contains_coeff_placeholder(value) {
      return true
    }
  }
  false
}

///|
fn coefficients_need_matrix_fallback(
  rows : Array[Array[Expr]],
  constants : Array[Expr],
) -> Bool {
  for row in rows {
    if coefficients_need_fallback(row) {
      return true
    }
  }
  coefficients_need_fallback(constants)
}

///|
fn contains_coeff_placeholder(expr : Expr) -> Bool {
  match expr {
    Expr::FunctionCall(name, args) =>
      if name == "coeff" {
        true
      } else {
        for arg in args {
          if contains_coeff_placeholder(arg) {
            return true
          }
        }
        false
      }
    Expr::Unary(_, inner) => contains_coeff_placeholder(inner)
    Expr::Binary(_, left, right) =>
      contains_coeff_placeholder(left) || contains_coeff_placeholder(right)
    _ => false
  }
}

///|
fn constant_term(expr : Expr, var_x : String, var_y : String) -> Expr {
  let without_x = substitute_variable_linear(expr, var_x, Expr::Int(0))
  let without_y = substitute_variable_linear(without_x, var_y, Expr::Int(0))
  simplify(without_y)
}

///|
fn constant_term_multi(expr : Expr, variable_names : Array[String]) -> Expr {
  let mut current = expr
  for name in variable_names {
    current = substitute_variable_linear(current, name, Expr::Int(0))
  }
  simplify(current)
}

///|
fn substitute_variable_linear(
  expr : Expr,
  variable_name : String,
  replacement : Expr,
) -> Expr {
  match expr {
    Expr::Int(_) => expr
    Expr::Double(_) => expr
    Expr::Symbol(symbol) =>
      if symbol.name == variable_name {
        replacement.copy()
      } else {
        expr
      }
    Expr::Unary(op, inner) => {
      let substituted = substitute_variable_linear(
        inner, variable_name, replacement,
      )
      Expr::Unary(op, substituted)
    }
    Expr::Binary(op, left, right) => {
      let new_left = substitute_variable_linear(
        left, variable_name, replacement,
      )
      let new_right = substitute_variable_linear(
        right, variable_name, replacement,
      )
      Expr::Binary(op, new_left, new_right)
    }
    Expr::FunctionCall(name, args) => {
      let new_args = Array::new(capacity=args.length())
      for arg in args {
        new_args.push(
          substitute_variable_linear(arg, variable_name, replacement),
        )
      }
      Expr::FunctionCall(name, new_args)
    }
  }
}

///|
fn solve_linear_fallback(
  variable_name : String,
  lhs : Expr,
  rhs : Expr,
) -> Expr {
  let args = Array::new()
  args.push(sym(variable_name))
  args.push(lhs)
  args.push(rhs)
  Expr::FunctionCall("solve_linear".to_string(), args)
}

///|
fn solve_linear_system_n_fallback(
  variable_names : Array[String],
  equations : Array[(Expr, Expr)],
) -> Array[Expr] {
  let args = Array::new()
  for name in variable_names {
    args.push(sym(name))
  }
  for idx in 0..<equations.length() {
    let (lhs, rhs) = equations[idx]
    args.push(lhs)
    args.push(rhs)
  }
  let fallback = Expr::FunctionCall("solve_linear_system_n".to_string(), args)
  let results = Array::new(capacity=variable_names.length())
  for _ in 0..<variable_names.length() {
    results.push(fallback.copy())
  }
  results
}

///|
fn no_solution_expr() -> Expr {
  Expr::FunctionCall("no_solution".to_string(), Array::new())
}

///|
fn build_no_solution_array(count : Int) -> Array[Expr] {
  let results = Array::new(capacity=count)
  for _ in 0..<count {
    results.push(no_solution_expr())
  }
  results
}

///|
fn has_non_linear_terms(expr : Expr, variable_name : String) -> Bool {
  let simplified = simplify(expr)
  if !expr_contains_variable_linear(simplified, variable_name) {
    return false
  }
  let max_iterations = 32
  let mut current = simplified
  let mut degree = 0
  while degree < max_iterations {
    degree = degree + 1
    let derivative = simplify(differentiate(current, variable_name))
    if contains_coeff_placeholder(derivative) {
      return true
    }
    if !expr_contains_variable_linear(derivative, variable_name) {
      return degree > 1
    }
    current = derivative
  }
  true
}

///|
fn expr_contains_variable_linear(expr : Expr, variable_name : String) -> Bool {
  match expr {
    Expr::Int(_) => false
    Expr::Double(_) => false
    Expr::Symbol(symbol) => symbol.name == variable_name
    Expr::Unary(_, inner) => expr_contains_variable_linear(inner, variable_name)
    Expr::Binary(_, left, right) =>
      expr_contains_variable_linear(left, variable_name) ||
      expr_contains_variable_linear(right, variable_name)
    Expr::FunctionCall(_, args) => {
      for arg in args {
        if expr_contains_variable_linear(arg, variable_name) {
          return true
        }
      }
      false
    }
  }
}

///|
fn literal_to_double(expr : Expr) -> Double? {
  match expr {
    Expr::Int(value) => Some(value.to_double())
    Expr::Double(value) => Some(value)
    Expr::Unary(UnaryOp::Neg, inner) =>
      match literal_to_double(inner) {
        Some(inner_value) => Some(-inner_value)
        None => None
      }
    Expr::Binary(BinaryOp::Div, left, right) =>
      match (literal_to_double(left), literal_to_double(right)) {
        (Some(lhs), Some(rhs)) => Some(lhs / rhs)
        _ => None
      }
    Expr::Binary(BinaryOp::Mul, left, right) =>
      match (literal_to_double(left), literal_to_double(right)) {
        (Some(lhs), Some(rhs)) => Some(lhs * rhs)
        _ => None
      }
    Expr::Binary(BinaryOp::Add, left, right) =>
      match (literal_to_double(left), literal_to_double(right)) {
        (Some(lhs), Some(rhs)) => Some(lhs + rhs)
        _ => None
      }
    Expr::Binary(BinaryOp::Sub, left, right) =>
      match (literal_to_double(left), literal_to_double(right)) {
        (Some(lhs), Some(rhs)) => Some(lhs - rhs)
        _ => None
      }
    _ => None
  }
}

///|
fn double_to_expr(value : Double) -> Expr {
  let rounded = value.round()
  if (value - rounded).abs() < 1.0e-9 {
    Expr::Int(rounded.to_int())
  } else {
    Expr::Double(value)
  }
}

///|
priv enum LinearSystemSolveResult {
  Unique(Array[Double])
  NoSolution
  Underdetermined
}

///|
fn solve_numeric_linear_system(
  coefficients : Array[Array[Double]],
  rhs : Array[Double],
) -> LinearSystemSolveResult {
  let size = coefficients.length()
  if rhs.length() != size || size == 0 {
    return LinearSystemSolveResult::Underdetermined
  }
  let augmented = Array::new(capacity=size)
  for row_idx in 0..<size {
    let coeff_row = coefficients[row_idx]
    if coeff_row.length() != size {
      return LinearSystemSolveResult::Underdetermined
    }
    let augmented_row = Array::new(capacity=size + 1)
    for value in coeff_row {
      augmented_row.push(value)
    }
    augmented_row.push(rhs[row_idx])
    augmented.push(augmented_row)
  }
  let mut pivot_row = 0
  for col in 0..<size {
    let mut best_row = pivot_row
    let mut best_value = 0.0
    for row_idx in pivot_row..<size {
      let candidate = augmented[row_idx][col].abs()
      if candidate > best_value {
        best_value = candidate
        best_row = row_idx
      }
    }
    if best_value < 1.0e-9 {
      continue
    }
    if best_row != pivot_row {
      let temp = augmented[best_row]
      augmented[best_row] = augmented[pivot_row]
      augmented[pivot_row] = temp
    }
    let pivot = augmented[pivot_row][col]
    for entry_idx in 0..<(size + 1) {
      augmented[pivot_row][entry_idx] = augmented[pivot_row][entry_idx] / pivot
    }
    for row_idx in 0..<size {
      if row_idx == pivot_row {
        continue
      }
      let factor = augmented[row_idx][col]
      if factor.abs() < 1.0e-12 {
        continue
      }
      for entry_idx in 0..<(size + 1) {
        augmented[row_idx][entry_idx] = augmented[row_idx][entry_idx] -
          factor * augmented[pivot_row][entry_idx]
      }
    }
    pivot_row = pivot_row + 1
  }
  for row_idx in pivot_row..<size {
    let mut coeff_zero = true
    for col_idx in 0..<size {
      if augmented[row_idx][col_idx].abs() > 1.0e-8 {
        coeff_zero = false
        break
      }
    }
    if coeff_zero && augmented[row_idx][size].abs() > 1.0e-8 {
      return LinearSystemSolveResult::NoSolution
    }
  }
  if pivot_row < size {
    return LinearSystemSolveResult::Underdetermined
  }
  let solution = Array::new(capacity=size)
  for row_idx in 0..<size {
    solution.push(augmented[row_idx][size])
  }
  LinearSystemSolveResult::Unique(solution)
}

///|
fn solve_linear_system_fallback(
  lhs1 : Expr,
  rhs1 : Expr,
  lhs2 : Expr,
  rhs2 : Expr,
  var_x : String,
  var_y : String,
) -> (Expr, Expr) {
  let args = Array::new()
  args.push(sym(var_x))
  args.push(sym(var_y))
  args.push(lhs1)
  args.push(rhs1)
  args.push(lhs2)
  args.push(rhs2)
  let fallback = Expr::FunctionCall("solve_linear_system".to_string(), args)
  (fallback.copy(), fallback)
}

///|
fn build_fraction(numerator : Expr, denominator : Expr) -> Expr {
  match denominator {
    Expr::Int(value) =>
      if value < 0 {
        let new_num = simplify(negate_expr(numerator))
        let new_den = Expr::Int(-value)
        return simplify(Expr::Binary(BinaryOp::Div, new_num, new_den))
      }
    Expr::Double(value) =>
      if value < 0.0 {
        let new_num = simplify(negate_expr(numerator))
        let new_den = Expr::Double(-value)
        return simplify(Expr::Binary(BinaryOp::Div, new_num, new_den))
      }
    Expr::Unary(UnaryOp::Neg, inner) => {
      let new_num = simplify(negate_expr(numerator))
      return build_fraction(new_num, inner)
    }
    _ => ()
  }
  simplify(Expr::Binary(BinaryOp::Div, numerator, denominator))
}

///|
fn negate_expr(expr : Expr) -> Expr {
  match expr {
    Expr::Unary(UnaryOp::Neg, inner) => inner
    _ => Expr::Unary(UnaryOp::Neg, expr)
  }
}

///|
fn is_zero_literal_linear(expr : Expr) -> Bool {
  match expr {
    Expr::Int(value) => value == 0
    Expr::Double(value) => value == 0.0
    Expr::Unary(UnaryOp::Neg, inner) => is_zero_literal(inner)
    _ => false
  }
}
