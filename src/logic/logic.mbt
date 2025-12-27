///|
pub enum LogicExpr {
  Bool(Bool)
  Symbol(String)
  Not(LogicExpr)
  And(Array[LogicExpr])
  Or(Array[LogicExpr])
  Xor(Array[LogicExpr])
  Ite(LogicExpr, LogicExpr, LogicExpr)
  Implies(LogicExpr, LogicExpr)
  Equivalent(LogicExpr, LogicExpr)
} derive(Show, Eq)

///|
pub fn LogicExpr::copy(self : LogicExpr) -> LogicExpr {
  match self {
    Bool(value) => Bool(value)
    Symbol(name) => Symbol(name)
    Not(inner) => Not(inner.copy())
    And(terms) => And(copy_terms(terms))
    Or(terms) => Or(copy_terms(terms))
    Xor(terms) => Xor(copy_terms(terms))
    Ite(condition, then_branch, else_branch) =>
      Ite(condition.copy(), then_branch.copy(), else_branch.copy())
    Implies(lhs, rhs) => Implies(lhs.copy(), rhs.copy())
    Equivalent(lhs, rhs) => Equivalent(lhs.copy(), rhs.copy())
  }
}

///|
fn copy_terms(terms : Array[LogicExpr]) -> Array[LogicExpr] {
  let len = terms.length()
  let copied = Array::new(capacity=len)
  for i in 0..<len {
    copied.push(terms[i].copy())
  }
  copied
}

///|
pub fn logic_not(expr : LogicExpr) -> LogicExpr {
  logic_not_canonical(logic_normalize(expr))
}

///|
pub fn logic_and(operands : Array[LogicExpr]) -> LogicExpr {
  logic_and_internal(normalize_operands(operands))
}

///|
pub fn logic_nand(operands : Array[LogicExpr]) -> LogicExpr {
  logic_not(logic_and(operands))
}

///|
pub fn logic_or(operands : Array[LogicExpr]) -> LogicExpr {
  logic_or_internal(normalize_operands(operands))
}

///|
pub fn logic_nor(operands : Array[LogicExpr]) -> LogicExpr {
  logic_not(logic_or(operands))
}

///|
pub fn logic_xor(operands : Array[LogicExpr]) -> LogicExpr {
  logic_xor_internal(normalize_operands(operands))
}

///|
pub fn logic_xnor(operands : Array[LogicExpr]) -> LogicExpr {
  logic_not(logic_xor(operands))
}

///|
pub fn logic_ite(
  condition : LogicExpr,
  then_branch : LogicExpr,
  else_branch : LogicExpr,
) -> LogicExpr {
  logic_ite_internal(
    logic_normalize(condition),
    logic_normalize(then_branch),
    logic_normalize(else_branch),
  )
}

///|
pub fn logic_implies(lhs : LogicExpr, rhs : LogicExpr) -> LogicExpr {
  logic_implies_internal(logic_normalize(lhs), logic_normalize(rhs))
}

///|
pub fn logic_equivalent(lhs : LogicExpr, rhs : LogicExpr) -> LogicExpr {
  logic_equivalent_internal(logic_normalize(lhs), logic_normalize(rhs))
}

///|
pub fn logic_normalize(expr : LogicExpr) -> LogicExpr {
  match expr {
    Bool(_) => expr
    Symbol(_) => expr
    Not(inner) => logic_not_canonical(logic_normalize(inner))
    And(terms) => logic_and_internal(normalize_operands(terms))
    Or(terms) => logic_or_internal(normalize_operands(terms))
    Xor(terms) => logic_xor_internal(normalize_operands(terms))
    Ite(condition, then_branch, else_branch) =>
      logic_ite_internal(
        logic_normalize(condition),
        logic_normalize(then_branch),
        logic_normalize(else_branch),
      )
    Implies(lhs, rhs) =>
      logic_implies_internal(logic_normalize(lhs), logic_normalize(rhs))
    Equivalent(lhs, rhs) =>
      logic_equivalent_internal(logic_normalize(lhs), logic_normalize(rhs))
  }
}

///|
pub fn logic_eval(
  expr : LogicExpr,
  assignments : Array[(String, Bool)],
) -> Bool? {
  let (_, result) = logic_eval_internal(logic_normalize(expr), assignments)
  result
}

///|
fn logic_eval_internal(
  expr : LogicExpr,
  assignments : Array[(String, Bool)],
) -> (Array[(String, Bool)], Bool?) {
  match expr {
    Bool(value) => (assignments, Some(value))
    Symbol(name) => (assignments, lookup_assignment(assignments, name))
    Not(inner) => {
      let (env, value) = logic_eval_internal(inner, assignments)
      match value {
        Some(result) => (env, Some(!result))
        None => (env, None)
      }
    }
    And(terms) => {
      let len = terms.length()
      let mut current = assignments
      let mut unknown = false
      for i in 0..<len {
        let (next, value) = logic_eval_internal(terms[i], current)
        current = next
        match value {
          Some(false) => return (current, Some(false))
          Some(true) => continue
          None => unknown = true
        }
      }
      if unknown {
        (current, None)
      } else {
        (current, Some(true))
      }
    }
    Or(terms) => {
      let len = terms.length()
      let mut current = assignments
      let mut unknown = false
      for i in 0..<len {
        let (next, value) = logic_eval_internal(terms[i], current)
        current = next
        match value {
          Some(true) => return (current, Some(true))
          Some(false) => continue
          None => unknown = true
        }
      }
      if unknown {
        (current, None)
      } else {
        (current, Some(false))
      }
    }
    Xor(terms) => {
      let len = terms.length()
      let mut current = assignments
      let mut parity = false
      let mut unknown = false
      for i in 0..<len {
        let (next, value) = logic_eval_internal(terms[i], current)
        current = next
        match value {
          Some(bit) => parity = parity != bit
          None => unknown = true
        }
      }
      if unknown {
        (current, None)
      } else {
        (current, Some(parity))
      }
    }
    Implies(lhs, rhs) => {
      let (env_after_lhs, left_value) = logic_eval_internal(lhs, assignments)
      let (env_after_rhs, right_value) = logic_eval_internal(rhs, env_after_lhs)
      let result = match left_value {
        Some(false) => Some(true)
        Some(true) => right_value
        None =>
          match right_value {
            Some(true) => Some(true)
            Some(false) => None
            None => None
          }
      }
      (env_after_rhs, result)
    }
    Equivalent(lhs, rhs) => {
      let (env_after_lhs, left_value) = logic_eval_internal(lhs, assignments)
      let (env_after_rhs, right_value) = logic_eval_internal(rhs, env_after_lhs)
      match (left_value, right_value) {
        (Some(left_bool), Some(right_bool)) =>
          (env_after_rhs, Some(left_bool == right_bool))
        _ => (env_after_rhs, None)
      }
    }
    Ite(condition, then_branch, else_branch) => {
      let (env_after_condition, condition_value) = logic_eval_internal(
        condition, assignments,
      )
      match condition_value {
        Some(true) => logic_eval_internal(then_branch, env_after_condition)
        Some(false) => logic_eval_internal(else_branch, env_after_condition)
        None => {
          let (env_after_then, then_value) = logic_eval_internal(
            then_branch, env_after_condition,
          )
          let (env_after_else, else_value) = logic_eval_internal(
            else_branch, env_after_then,
          )
          match (then_value, else_value) {
            (Some(lhs_bool), Some(rhs_bool)) =>
              if lhs_bool == rhs_bool {
                (env_after_else, Some(lhs_bool))
              } else {
                (env_after_else, None)
              }
            _ => (env_after_else, None)
          }
        }
      }
    }
  }
}

///|
fn lookup_assignment(
  assignments : Array[(String, Bool)],
  name : String,
) -> Bool? {
  for i in assignments {
    let (key, value) = i
    if key == name {
      return Some(value)
    }
  }
  None
}

///|
pub fn logic_collect_variables(expr : LogicExpr) -> Array[String] {
  let seen : Map[String, Bool] = {}
  let names = Array::new()
  let (_, collected) = collect_variables_internal(expr, seen, names)
  sort_strings(collected)
}

///|
pub fn logic_collect_subexpressions(expr : LogicExpr) -> Array[LogicExpr] {
  let seen : Map[String, Bool] = {}
  let collected = Array::new()
  let (_, results) = collect_subexpressions_internal(expr, seen, collected)
  sort_terms_by_signature(results)
}

///|
pub fn logic_to_anf(expr : LogicExpr) -> LogicExpr {
  let normalized = logic_normalize(expr)
  let variables = logic_collect_variables(normalized.copy())
  let variable_count = variables.length()
  let total = pow_two(variable_count)
  let values = Array::new(capacity=total)
  let symbols = Array::new(capacity=variable_count)
  for name in variables {
    symbols.push(logic_symbol(name))
  }
  let mut index = 0
  while index < total {
    let assignment = assignment_from_index(index, variable_count)
    let env = Array::new(capacity=variable_count)
    let mut i = 0
    while i < variable_count {
      env.push((variables[i], assignment[i]))
      i += 1
    }
    let value = match logic_eval(normalized.copy(), env) {
      Some(true) => true
      _ => false
    }
    values.push(value)
    index += 1
  }
  let coeffs = anf_coefficients_from_values(values, variable_count)
  let terms = Array::new()
  let mut mask = 0
  while mask < total {
    if coeffs[mask] {
      terms.push(anf_term_from_mask(symbols, mask))
    }
    mask += 1
  }
  if terms.length() == 0 {
    logic_false()
  } else if terms.length() == 1 {
    terms[0]
  } else {
    logic_xor(terms)
  }
}

///|
fn anf_coefficients_from_values(
  values : Array[Bool],
  variable_count : Int,
) -> Array[Bool] {
  let coeffs = values
  let total = coeffs.length()
  let mut i = 0
  while i < variable_count {
    let bit = 1 << i
    let mut mask = 0
    while mask < total {
      if (mask & bit) != 0 {
        coeffs[mask] = coeffs[mask] != coeffs[mask ^ bit]
      }
      mask += 1
    }
    i += 1
  }
  coeffs
}

///|
fn anf_term_from_mask(symbols : Array[LogicExpr], mask : Int) -> LogicExpr {
  if mask == 0 {
    return logic_true()
  }
  let factors = Array::new()
  let len = symbols.length()
  let mut i = 0
  while i < len {
    if (mask & (1 << i)) != 0 {
      factors.push(symbols[i].copy())
    }
    i += 1
  }
  if factors.length() == 1 {
    factors[0]
  } else {
    logic_and(factors)
  }
}

///|
pub fn logic_to_dnf(expr : LogicExpr) -> LogicExpr {
  let normalized = logic_normalize(expr)
  let variables = logic_collect_variables(normalized.copy())
  let variable_count = variables.length()
  let total = pow_two(variable_count)
  let rows = Array::new(capacity=total)
  let mut index = 0
  while index < total {
    let assignment = assignment_from_index(index, variable_count)
    let env = Array::new(capacity=variable_count)
    let mut i = 0
    while i < variable_count {
      env.push((variables[i], assignment[i]))
      i += 1
    }
    match logic_eval(normalized.copy(), env) {
      Some(value) => rows.push((assignment, value))
      None => rows.push((assignment, false))
    }
    index += 1
  }
  logic_from_truth_table(variables, rows)
}

///|
pub fn logic_to_nnf(expr : LogicExpr, simplify? : Bool = true) -> LogicExpr {
  let normalized = logic_normalize(expr)
  let nnf = logic_to_nnf_internal(normalized, false, simplify)
  if simplify {
    logic_normalize(nnf)
  } else {
    nnf
  }
}

///|
pub fn logic_to_cnf(expr : LogicExpr) -> LogicExpr {
  let normalized = logic_normalize(expr)
  let variables = logic_collect_variables(normalized.copy())
  let variable_count = variables.length()
  let total = pow_two(variable_count)
  let clauses = Array::new()
  let mut index = 0
  while index < total {
    let assignment = assignment_from_index(index, variable_count)
    let env = Array::new(capacity=variable_count)
    let mut i = 0
    while i < variable_count {
      env.push((variables[i], assignment[i]))
      i += 1
    }
    match logic_eval(normalized.copy(), env) {
      Some(false) =>
        clauses.push(cnf_clause_from_assignment(variables, assignment))
      None => clauses.push(cnf_clause_from_assignment(variables, assignment))
      _ => ()
    }
    index += 1
  }
  let len = clauses.length()
  if len == 0 {
    logic_true()
  } else if len == 1 {
    clauses[0]
  } else {
    logic_and(clauses)
  }
}

///|
fn logic_to_nnf_internal(
  expr : LogicExpr,
  negate : Bool,
  simplify : Bool,
) -> LogicExpr {
  match expr {
    Bool(value) => LogicExpr::Bool(if negate { !value } else { value })
    Symbol(name) => {
      let symbol = LogicExpr::Symbol(name)
      if negate {
        if simplify {
          logic_not_canonical(symbol)
        } else {
          LogicExpr::Not(symbol)
        }
      } else {
        symbol
      }
    }
    Not(inner) => logic_to_nnf_internal(inner, !negate, simplify)
    And(terms) => {
      let mapped = nnf_map_terms(terms, negate, simplify)
      if negate {
        nnf_build_or(mapped, simplify)
      } else {
        nnf_build_and(mapped, simplify)
      }
    }
    Or(terms) => {
      let mapped = nnf_map_terms(terms, negate, simplify)
      if negate {
        nnf_build_and(mapped, simplify)
      } else {
        nnf_build_or(mapped, simplify)
      }
    }
    Xor(terms) => {
      let expanded = xor_expand_terms(terms)
      logic_to_nnf_internal(expanded, negate, simplify)
    }
    Implies(lhs, rhs) => {
      let expanded = LogicExpr::Or([LogicExpr::Not(lhs), rhs])
      logic_to_nnf_internal(expanded, negate, simplify)
    }
    Equivalent(lhs, rhs) => {
      let lhs_copy = lhs.copy()
      let rhs_copy = rhs.copy()
      let expanded = LogicExpr::Or([
        LogicExpr::And([lhs_copy, rhs_copy]),
        LogicExpr::And([LogicExpr::Not(lhs), LogicExpr::Not(rhs)]),
      ])
      logic_to_nnf_internal(expanded, negate, simplify)
    }
    Ite(condition, then_branch, else_branch) => {
      let cond_copy = condition.copy()
      let expanded = LogicExpr::Or([
        LogicExpr::And([cond_copy, then_branch]),
        LogicExpr::And([LogicExpr::Not(condition), else_branch]),
      ])
      logic_to_nnf_internal(expanded, negate, simplify)
    }
  }
}

///|
fn nnf_map_terms(
  terms : Array[LogicExpr],
  negate : Bool,
  simplify : Bool,
) -> Array[LogicExpr] {
  let len = terms.length()
  let mapped = Array::new(capacity=len)
  let mut i = 0
  while i < len {
    mapped.push(logic_to_nnf_internal(terms[i], negate, simplify))
    i += 1
  }
  mapped
}

///|
fn nnf_build_and(terms : Array[LogicExpr], simplify : Bool) -> LogicExpr {
  if simplify {
    logic_and(terms)
  } else {
    let len = terms.length()
    if len == 0 {
      LogicExpr::Bool(true)
    } else if len == 1 {
      terms[0]
    } else {
      LogicExpr::And(terms)
    }
  }
}

///|
fn nnf_build_or(terms : Array[LogicExpr], simplify : Bool) -> LogicExpr {
  if simplify {
    logic_or(terms)
  } else {
    let len = terms.length()
    if len == 0 {
      LogicExpr::Bool(false)
    } else if len == 1 {
      terms[0]
    } else {
      LogicExpr::Or(terms)
    }
  }
}

///|
fn xor_expand_terms(terms : Array[LogicExpr]) -> LogicExpr {
  let len = terms.length()
  if len == 0 {
    return LogicExpr::Bool(false)
  }
  let mut acc = terms[0].copy()
  let mut i = 1
  while i < len {
    acc = xor_expand_binary(acc, terms[i].copy())
    i += 1
  }
  acc
}

///|
fn xor_expand_binary(lhs : LogicExpr, rhs : LogicExpr) -> LogicExpr {
  LogicExpr::Or([
    LogicExpr::And([lhs.copy(), LogicExpr::Not(rhs.copy())]),
    LogicExpr::And([LogicExpr::Not(lhs), rhs]),
  ])
}

///|
pub fn logic_simplify_logic(expr : LogicExpr, mode : String) -> LogicExpr {
  let normalized = logic_normalize(expr)
  if mode == "dnf" {
    return logic_to_dnf(normalized)
  }
  if mode == "cnf" {
    return logic_to_cnf(normalized)
  }
  if mode == "both" {
    let dnf = logic_to_dnf(normalized.copy())
    let cnf = logic_to_cnf(normalized)
    let dnf_cost = logic_expr_complexity(dnf.copy())
    let cnf_cost = logic_expr_complexity(cnf.copy())
    if cnf_cost < dnf_cost {
      return cnf
    } else {
      return dnf
    }
  }
  abort("unknown simplify mode: " + mode)
}

///|
pub fn logic_expr_depth(expr : LogicExpr) -> Int {
  logic_expr_depth_internal(expr)
}

///|
pub fn logic_expr_complexity(expr : LogicExpr) -> Int {
  logic_expr_complexity_internal(expr)
}

///|
pub fn logic_atoms(expr : LogicExpr) -> Array[LogicExpr] {
  let names = logic_collect_variables(expr)
  let atoms = Array::new(capacity=names.length())
  for name in names {
    atoms.push(logic_symbol(name))
  }
  atoms
}

///|
pub fn logic_func(expr : LogicExpr) -> String {
  match expr {
    Bool(_) => "Bool"
    Symbol(_) => "Symbol"
    Not(_) => LOGIC_NOT_SYMBOL
    And(_) => LOGIC_AND_SYMBOL
    Or(_) => LOGIC_OR_SYMBOL
    Xor(_) => LOGIC_XOR_SYMBOL
    Ite(_, _, _) => LOGIC_ITE_SYMBOL
    Implies(_, _) => LOGIC_IMPLIES_SYMBOL
    Equivalent(_, _) => LOGIC_EQUIVALENT_SYMBOL
  }
}

///|
pub fn logic_args(expr : LogicExpr) -> Array[LogicExpr] {
  match expr {
    Bool(_) => Array::new()
    Symbol(_) => Array::new()
    Not(inner) => [inner]
    And(terms) => terms
    Or(terms) => terms
    Xor(terms) => terms
    Ite(condition, then_branch, else_branch) =>
      [condition, then_branch, else_branch]
    Implies(lhs, rhs) => [lhs, rhs]
    Equivalent(lhs, rhs) => [lhs, rhs]
  }
}

///|
pub fn logic_op_count(expr : LogicExpr) -> Int {
  match expr {
    Bool(_) => 0
    Symbol(_) => 0
    Not(inner) => 1 + logic_op_count(inner)
    And(terms) => 1 + sum_op_count_terms(terms)
    Or(terms) => 1 + sum_op_count_terms(terms)
    Xor(terms) => 1 + sum_op_count_terms(terms)
    Ite(condition, then_branch, else_branch) => {
      let mut total = 1
      total += logic_op_count(condition)
      total += logic_op_count(then_branch)
      total += logic_op_count(else_branch)
      total
    }
    Implies(lhs, rhs) => 1 + logic_op_count(lhs) + logic_op_count(rhs)
    Equivalent(lhs, rhs) => 1 + logic_op_count(lhs) + logic_op_count(rhs)
  }
}

///|
pub fn logic_gate_input_count(expr : LogicExpr) -> Int {
  logic_gate_input_count_internal(logic_normalize(expr))
}

///|
fn logic_gate_input_count_internal(expr : LogicExpr) -> Int {
  match expr {
    Bool(_) => 0
    Symbol(_) => 0
    Not(inner) => 1 + logic_gate_input_count_internal(inner)
    And(terms) => terms.length() + gate_input_count_terms(terms)
    Or(terms) => terms.length() + gate_input_count_terms(terms)
    Xor(terms) => terms.length() + gate_input_count_terms(terms)
    Ite(condition, then_branch, else_branch) => {
      let mut total = 3
      total += logic_gate_input_count_internal(condition)
      total += logic_gate_input_count_internal(then_branch)
      total += logic_gate_input_count_internal(else_branch)
      total
    }
    Implies(lhs, rhs) =>
      2 +
      logic_gate_input_count_internal(lhs) +
      logic_gate_input_count_internal(rhs)
    Equivalent(lhs, rhs) =>
      2 +
      logic_gate_input_count_internal(lhs) +
      logic_gate_input_count_internal(rhs)
  }
}

///|
fn gate_input_count_terms(terms : Array[LogicExpr]) -> Int {
  let mut total = 0
  for term in terms {
    total += logic_gate_input_count_internal(term)
  }
  total
}

///|
pub fn logic_is_literal(expr : LogicExpr) -> Bool {
  match expr {
    Bool(_) => true
    Symbol(_) => true
    Not(inner) =>
      match inner {
        Symbol(_) => true
        _ => false
      }
    _ => false
  }
}

///|
pub fn logic_is_cnf(expr : LogicExpr) -> Bool {
  match expr {
    Bool(_) => true
    Symbol(_) => true
    Not(_) => logic_is_literal(expr)
    And(clauses) => {
      for clause in clauses {
        if !logic_is_clause(clause) {
          return false
        }
      }
      true
    }
    _ => logic_is_clause(expr)
  }
}

///|
pub fn logic_is_dnf(expr : LogicExpr) -> Bool {
  match expr {
    Bool(_) => true
    Symbol(_) => true
    Not(_) => logic_is_literal(expr)
    Or(terms) => {
      for term in terms {
        if !logic_is_conjunction_of_literals(term) {
          return false
        }
      }
      true
    }
    _ => logic_is_conjunction_of_literals(expr)
  }
}

///|
pub fn logic_is_nnf(expr : LogicExpr, simplified? : Bool = true) -> Bool {
  if !logic_is_nnf_internal(expr) {
    return false
  }
  if simplified {
    let normalized = logic_normalize(expr.copy())
    normalized == expr
  } else {
    true
  }
}

///|
fn logic_is_nnf_internal(expr : LogicExpr) -> Bool {
  match expr {
    Bool(_) => true
    Symbol(_) => true
    Not(inner) =>
      match inner {
        Bool(_) => true
        Symbol(_) => true
        _ => false
      }
    And(terms) => {
      for term in terms {
        if !logic_is_nnf_internal(term) {
          return false
        }
      }
      true
    }
    Or(terms) => {
      for term in terms {
        if !logic_is_nnf_internal(term) {
          return false
        }
      }
      true
    }
    _ => false
  }
}

///|
pub fn logic_is_anf(expr : LogicExpr) -> Bool {
  match expr {
    Not(inner) => logic_is_anf_core(inner)
    _ => logic_is_anf_core(expr)
  }
}

///|
fn logic_is_anf_core(expr : LogicExpr) -> Bool {
  match expr {
    Bool(_) => true
    Symbol(_) => true
    And(terms) => logic_is_anf_monomial_terms(terms)
    Xor(terms) => {
      for term in terms {
        if !logic_is_anf_monomial(term) {
          return false
        }
      }
      true
    }
    _ => false
  }
}

///|
fn logic_is_anf_monomial(expr : LogicExpr) -> Bool {
  match expr {
    Bool(_) => true
    Symbol(_) => true
    And(terms) => logic_is_anf_monomial_terms(terms)
    _ => false
  }
}

///|
fn logic_is_anf_monomial_terms(terms : Array[LogicExpr]) -> Bool {
  for term in terms {
    match term {
      Symbol(_) => ()
      _ => return false
    }
  }
  true
}

///|
fn logic_is_clause(expr : LogicExpr) -> Bool {
  match expr {
    Or(terms) => {
      for term in terms {
        if !logic_is_literal(term) {
          return false
        }
      }
      true
    }
    _ => logic_is_literal(expr)
  }
}

///|
fn logic_is_conjunction_of_literals(expr : LogicExpr) -> Bool {
  match expr {
    And(terms) => {
      for term in terms {
        if !logic_is_literal(term) {
          return false
        }
      }
      true
    }
    _ => logic_is_literal(expr)
  }
}

///|
pub fn to_anf(expr : LogicExpr) -> LogicExpr {
  logic_to_anf(expr)
}

///|
pub fn to_cnf(expr : LogicExpr, simplify? : Bool = false) -> LogicExpr {
  let result = logic_to_cnf(expr)
  if simplify {
    logic_normalize(result)
  } else {
    result
  }
}

///|
pub fn to_dnf(expr : LogicExpr, simplify? : Bool = false) -> LogicExpr {
  let result = logic_to_dnf(expr)
  if simplify {
    logic_normalize(result)
  } else {
    result
  }
}

///|
pub fn to_nnf(expr : LogicExpr, simplify? : Bool = true) -> LogicExpr {
  logic_to_nnf(expr, simplify~)
}

///|
pub fn is_anf(expr : LogicExpr) -> Bool {
  logic_is_anf(expr)
}

///|
pub fn is_cnf(expr : LogicExpr) -> Bool {
  logic_is_cnf(expr)
}

///|
pub fn is_dnf(expr : LogicExpr) -> Bool {
  logic_is_dnf(expr)
}

///|
pub fn is_nnf(expr : LogicExpr, simplified? : Bool = true) -> Bool {
  logic_is_nnf(expr, simplified~)
}

///|
pub fn gateinputcount(expr : LogicExpr) -> Int {
  logic_gate_input_count(expr)
}

///|
pub fn logic_preorder(expr : LogicExpr) -> Array[LogicExpr] {
  let nodes = Array::new()
  preorder_collect(expr, nodes)
}

///|
pub fn logic_preorder_with_depth(
  expr : LogicExpr,
  depth? : Int = 0,
) -> Array[(Int, LogicExpr)] {
  let nodes = Array::new()
  preorder_collect_with_depth(expr, depth, nodes)
}

///|
fn collect_variables_internal(
  expr : LogicExpr,
  seen : Map[String, Bool],
  names : Array[String],
) -> (Map[String, Bool], Array[String]) {
  match expr {
    Bool(_) => (seen, names)
    Symbol(name) => register_variable(name, seen, names)
    Not(inner) => collect_variables_internal(inner, seen, names)
    And(terms) => collect_variables_from_terms(terms, seen, names)
    Or(terms) => collect_variables_from_terms(terms, seen, names)
    Xor(terms) => collect_variables_from_terms(terms, seen, names)
    Ite(condition, then_branch, else_branch) => {
      let (after_condition, names_after_condition) = collect_variables_internal(
        condition, seen, names,
      )
      let (after_then, names_after_then) = collect_variables_internal(
        then_branch, after_condition, names_after_condition,
      )
      collect_variables_internal(else_branch, after_then, names_after_then)
    }
    Implies(lhs, rhs) => {
      let (after_lhs, names_after_lhs) = collect_variables_internal(
        lhs, seen, names,
      )
      collect_variables_internal(rhs, after_lhs, names_after_lhs)
    }
    Equivalent(lhs, rhs) => {
      let (after_lhs, names_after_lhs) = collect_variables_internal(
        lhs, seen, names,
      )
      collect_variables_internal(rhs, after_lhs, names_after_lhs)
    }
  }
}

///|
fn collect_variables_from_terms(
  terms : Array[LogicExpr],
  seen : Map[String, Bool],
  names : Array[String],
) -> (Map[String, Bool], Array[String]) {
  let len = terms.length()
  let mut current_seen = seen
  let mut current_names = names
  for i in 0..<len {
    let (next_seen, next_names) = collect_variables_internal(
      terms[i],
      current_seen,
      current_names,
    )
    current_seen = next_seen
    current_names = next_names
  }
  (current_seen, current_names)
}

///|
fn register_variable(
  name : String,
  seen : Map[String, Bool],
  names : Array[String],
) -> (Map[String, Bool], Array[String]) {
  if seen.contains(name) {
    (seen, names)
  } else {
    let updated_seen = seen
    updated_seen.set(name, true)
    let updated_names = names
    updated_names.push(name)
    (updated_seen, updated_names)
  }
}

///|
fn collect_subexpressions_internal(
  expr : LogicExpr,
  seen : Map[String, Bool],
  subexprs : Array[LogicExpr],
) -> (Map[String, Bool], Array[LogicExpr]) {
  let signature = logic_signature(expr.copy())
  let current_seen = seen
  let current_subexprs = subexprs
  if !current_seen.contains(signature) {
    current_seen.set(signature, true)
    current_subexprs.push(expr.copy())
  }
  match expr {
    Bool(_) => (current_seen, current_subexprs)
    Symbol(_) => (current_seen, current_subexprs)
    Not(inner) =>
      collect_subexpressions_internal(inner, current_seen, current_subexprs)
    And(terms) =>
      collect_subexpressions_from_terms(terms, current_seen, current_subexprs)
    Or(terms) =>
      collect_subexpressions_from_terms(terms, current_seen, current_subexprs)
    Xor(terms) =>
      collect_subexpressions_from_terms(terms, current_seen, current_subexprs)
    Ite(condition, then_branch, else_branch) => {
      let (after_condition, after_condition_subexprs) = collect_subexpressions_internal(
        condition, current_seen, current_subexprs,
      )
      let (after_then, after_then_subexprs) = collect_subexpressions_internal(
        then_branch, after_condition, after_condition_subexprs,
      )
      collect_subexpressions_internal(
        else_branch, after_then, after_then_subexprs,
      )
    }
    Implies(lhs, rhs) => {
      let (after_lhs, after_lhs_subexprs) = collect_subexpressions_internal(
        lhs, current_seen, current_subexprs,
      )
      collect_subexpressions_internal(rhs, after_lhs, after_lhs_subexprs)
    }
    Equivalent(lhs, rhs) => {
      let (after_lhs, after_lhs_subexprs) = collect_subexpressions_internal(
        lhs, current_seen, current_subexprs,
      )
      collect_subexpressions_internal(rhs, after_lhs, after_lhs_subexprs)
    }
  }
}

///|
fn collect_subexpressions_from_terms(
  terms : Array[LogicExpr],
  seen : Map[String, Bool],
  subexprs : Array[LogicExpr],
) -> (Map[String, Bool], Array[LogicExpr]) {
  let len = terms.length()
  let mut current_seen = seen
  let mut current_subexprs = subexprs
  for i in 0..<len {
    let (next_seen, next_subexprs) = collect_subexpressions_internal(
      terms[i],
      current_seen,
      current_subexprs,
    )
    current_seen = next_seen
    current_subexprs = next_subexprs
  }
  (current_seen, current_subexprs)
}

///|
fn logic_expr_depth_internal(expr : LogicExpr) -> Int {
  match expr {
    Bool(_) => 1
    Symbol(_) => 1
    Not(inner) => 1 + logic_expr_depth_internal(inner)
    And(terms) => 1 + maximum_depth_in_terms(terms)
    Or(terms) => 1 + maximum_depth_in_terms(terms)
    Xor(terms) => 1 + maximum_depth_in_terms(terms)
    Ite(condition, then_branch, else_branch) => {
      let cond_depth = logic_expr_depth_internal(condition)
      let then_depth = logic_expr_depth_internal(then_branch)
      let else_depth = logic_expr_depth_internal(else_branch)
      let mut best = cond_depth
      if then_depth > best {
        best = then_depth
      }
      if else_depth > best {
        best = else_depth
      }
      1 + best
    }
    Implies(lhs, rhs) => {
      let left_depth = logic_expr_depth_internal(lhs)
      let right_depth = logic_expr_depth_internal(rhs)
      let mut best = left_depth
      if right_depth > best {
        best = right_depth
      }
      1 + best
    }
    Equivalent(lhs, rhs) => {
      let left_depth = logic_expr_depth_internal(lhs)
      let right_depth = logic_expr_depth_internal(rhs)
      let mut best = left_depth
      if right_depth > best {
        best = right_depth
      }
      1 + best
    }
  }
}

///|
fn maximum_depth_in_terms(terms : Array[LogicExpr]) -> Int {
  let len = terms.length()
  if len == 0 {
    return 0
  }
  let mut best = 0
  for term in terms {
    let depth = logic_expr_depth_internal(term)
    if depth > best {
      best = depth
    }
  }
  best
}

///|
fn logic_expr_complexity_internal(expr : LogicExpr) -> Int {
  match expr {
    Bool(_) => 1
    Symbol(_) => 1
    Not(inner) => 1 + logic_expr_complexity_internal(inner)
    And(terms) => 1 + sum_complexity_terms(terms)
    Or(terms) => 1 + sum_complexity_terms(terms)
    Xor(terms) => 1 + sum_complexity_terms(terms)
    Ite(condition, then_branch, else_branch) => {
      let mut total = 1
      total += logic_expr_complexity_internal(condition)
      total += logic_expr_complexity_internal(then_branch)
      total += logic_expr_complexity_internal(else_branch)
      total
    }
    Implies(lhs, rhs) => {
      let mut total = 1
      total += logic_expr_complexity_internal(lhs)
      total += logic_expr_complexity_internal(rhs)
      total
    }
    Equivalent(lhs, rhs) => {
      let mut total = 1
      total += logic_expr_complexity_internal(lhs)
      total += logic_expr_complexity_internal(rhs)
      total
    }
  }
}

///|
fn sum_complexity_terms(terms : Array[LogicExpr]) -> Int {
  let mut total = 0
  for term in terms {
    total += logic_expr_complexity_internal(term)
  }
  total
}

///|
fn preorder_collect(
  expr : LogicExpr,
  nodes : Array[LogicExpr],
) -> Array[LogicExpr] {
  nodes.push(expr)
  let children = logic_args(expr)
  let len = children.length()
  for i in 0..<len {
    let child = children[i]
    let _ = preorder_collect(child, nodes)

  }
  nodes
}

///|
fn preorder_collect_with_depth(
  expr : LogicExpr,
  depth : Int,
  nodes : Array[(Int, LogicExpr)],
) -> Array[(Int, LogicExpr)] {
  nodes.push((depth, expr))
  let children = logic_args(expr)
  let len = children.length()
  for i in 0..<len {
    let child = children[i]
    let _ = preorder_collect_with_depth(child, depth + 1, nodes)

  }
  nodes
}

///|
fn sum_op_count_terms(terms : Array[LogicExpr]) -> Int {
  let mut total = 0
  for term in terms {
    total += logic_op_count(term)
  }
  total
}

///|
fn pow_two(exp : Int) -> Int {
  let mut result = 1
  let mut i = 0
  while i < exp {
    result = result * 2
    i += 1
  }
  result
}

///|
fn assignment_from_index(index : Int, count : Int) -> Array[Bool] {
  let assignment = Array::new(capacity=count)
  let mut remaining = index
  let mut i = 0
  while i < count {
    assignment.push(remaining % 2 != 0)
    remaining = remaining / 2
    i += 1
  }
  assignment
}

///|
pub fn gate_not(input : Bool) -> Bool {
  !input
}

///|
pub fn gate_and(inputs : Array[Bool]) -> Bool {
  let len = inputs.length()
  let mut i = 0
  while i < len {
    if inputs[i] == false {
      return false
    }
    i += 1
  }
  true
}

///|
pub fn gate_or(inputs : Array[Bool]) -> Bool {
  let len = inputs.length()
  let mut i = 0
  while i < len {
    if inputs[i] {
      return true
    }
    i += 1
  }
  false
}

///|
pub fn gate_nand(inputs : Array[Bool]) -> Bool {
  !gate_and(inputs)
}

///|
pub fn gate_nor(inputs : Array[Bool]) -> Bool {
  !gate_or(inputs)
}

///|
pub fn gate_xor(inputs : Array[Bool]) -> Bool {
  let len = inputs.length()
  let mut parity = false
  let mut i = 0
  while i < len {
    parity = parity != inputs[i]
    i += 1
  }
  parity
}

///|
pub fn gate_xnor(inputs : Array[Bool]) -> Bool {
  !gate_xor(inputs)
}

///|
fn cnf_clause_from_assignment(
  variables : Array[String],
  assignment : Array[Bool],
) -> LogicExpr {
  let len = variables.length()
  let disjuncts = Array::new(capacity=len)
  let mut i = 0
  while i < len {
    let symbol = logic_symbol(variables[i])
    if assignment[i] {
      disjuncts.push(logic_not(symbol))
    } else {
      disjuncts.push(symbol)
    }
    i += 1
  }
  logic_or(disjuncts)
}

///|
fn normalize_operands(operands : Array[LogicExpr]) -> Array[LogicExpr] {
  let len = operands.length()
  let normalized = Array::new(capacity=len)
  for i in 0..<len {
    normalized.push(logic_normalize(operands[i]))
  }
  normalized
}

///|
fn logic_not_canonical(operand : LogicExpr) -> LogicExpr {
  match operand {
    Bool(value) => Bool(!value)
    Not(inner) => inner
    _ => Not(operand)
  }
}

///|
fn logic_and_internal(operands : Array[LogicExpr]) -> LogicExpr {
  if operands.length() == 0 {
    return Bool(true)
  }
  let mut current_seen : Map[String, Bool] = {}
  let mut current_terms = Array::new()
  let len = operands.length()
  for i in 0..<len {
    let operand = operands[i]
    let (next_seen, next_terms, halted) = absorb_and_operand(
      operand, current_seen, current_terms,
    )
    current_seen = next_seen
    current_terms = next_terms
    if halted {
      return Bool(false)
    }
  }
  let count = current_terms.length()
  if count == 0 {
    Bool(true)
  } else if count == 1 {
    current_terms[0]
  } else {
    let sorted = sort_terms_by_signature(current_terms)
    And(sorted)
  }
}

///|
fn logic_or_internal(operands : Array[LogicExpr]) -> LogicExpr {
  if operands.length() == 0 {
    return Bool(false)
  }
  let mut current_seen : Map[String, Bool] = {}
  let mut current_terms = Array::new()
  let len = operands.length()
  for i in 0..<len {
    let operand = operands[i]
    let (next_seen, next_terms, halted) = absorb_or_operand(
      operand, current_seen, current_terms,
    )
    current_seen = next_seen
    current_terms = next_terms
    if halted {
      return Bool(true)
    }
  }
  let count = current_terms.length()
  if count == 0 {
    Bool(false)
  } else if count == 1 {
    current_terms[0]
  } else {
    let sorted = sort_terms_by_signature(current_terms)
    Or(sorted)
  }
}

///|
fn logic_xor_internal(operands : Array[LogicExpr]) -> LogicExpr {
  if operands.length() == 0 {
    return Bool(false)
  }
  let len = operands.length()
  let mut parity = false
  let mut current_terms = Array::new()
  for i in 0..<len {
    let operand = operands[i]
    match operand {
      Bool(value) => parity = parity != value
      Xor(inner) => {
        let collapsed = logic_xor_internal(normalize_operands(inner))
        match collapsed {
          Bool(value) => parity = parity != value
          other => current_terms = xor_toggle(current_terms, other)
        }
      }
      other => current_terms = xor_toggle(current_terms, other)
    }
  }
  let count = current_terms.length()
  if count == 0 {
    Bool(parity)
  } else {
    let base = if count == 1 {
      current_terms[0]
    } else {
      let sorted = sort_terms_by_signature(current_terms)
      Xor(sorted)
    }
    if parity {
      logic_not_canonical(base)
    } else {
      base
    }
  }
}

///|
fn absorb_and_operand(
  operand : LogicExpr,
  seen : Map[String, Bool],
  terms : Array[LogicExpr],
) -> (Map[String, Bool], Array[LogicExpr], Bool) {
  match operand {
    Bool(value) => (seen, terms, !value)
    And(inner) => {
      let len = inner.length()
      let mut current_seen = seen
      let mut current_terms = terms
      for i in 0..<len {
        let (next_seen, next_terms, halted) = absorb_and_operand(
          inner[i],
          current_seen,
          current_terms,
        )
        current_seen = next_seen
        current_terms = next_terms
        if halted {
          return (current_seen, current_terms, true)
        }
      }
      (current_seen, current_terms, false)
    }
    other => {
      let signature = logic_signature(other.copy())
      if seen.contains(signature) {
        return (seen, terms, false)
      }
      let neg_signature = logic_negation_signature(other.copy())
      if seen.contains(neg_signature) {
        return (seen, terms, true)
      }
      let updated_terms = terms
      updated_terms.push(other)
      let updated_seen = seen
      updated_seen.set(signature, true)
      (updated_seen, updated_terms, false)
    }
  }
}

///|
fn absorb_or_operand(
  operand : LogicExpr,
  seen : Map[String, Bool],
  terms : Array[LogicExpr],
) -> (Map[String, Bool], Array[LogicExpr], Bool) {
  match operand {
    Bool(value) => (seen, terms, value)
    Or(inner) => {
      let len = inner.length()
      let mut current_seen = seen
      let mut current_terms = terms
      for i in 0..<len {
        let (next_seen, next_terms, halted) = absorb_or_operand(
          inner[i],
          current_seen,
          current_terms,
        )
        current_seen = next_seen
        current_terms = next_terms
        if halted {
          return (current_seen, current_terms, true)
        }
      }
      (current_seen, current_terms, false)
    }
    other => {
      let signature = logic_signature(other.copy())
      if seen.contains(signature) {
        return (seen, terms, false)
      }
      let neg_signature = logic_negation_signature(other.copy())
      if seen.contains(neg_signature) {
        return (seen, terms, true)
      }
      let updated_terms = terms
      updated_terms.push(other)
      let updated_seen = seen
      updated_seen.set(signature, true)
      (updated_seen, updated_terms, false)
    }
  }
}

///|
fn xor_toggle(terms : Array[LogicExpr], expr : LogicExpr) -> Array[LogicExpr] {
  let len = terms.length()
  for i in 0..<len {
    if terms[i] == expr {
      return remove_index(terms, i)
    }
  }
  let updated = terms
  updated.push(expr)
  updated
}

///|
fn remove_index(source : Array[LogicExpr], index : Int) -> Array[LogicExpr] {
  let result = Array::new()
  let len = source.length()
  for i in 0..<len {
    if i == index {
      continue
    }
    result.push(source[i])
  }
  result
}

///|
fn logic_implies_internal(lhs : LogicExpr, rhs : LogicExpr) -> LogicExpr {
  match lhs {
    Bool(false) => Bool(true)
    Bool(true) => rhs
    _ =>
      match rhs {
        Bool(true) => Bool(true)
        Bool(false) => logic_not_canonical(lhs)
        _ => {
          let operands = Array::new(capacity=2)
          operands.push(logic_not_canonical(lhs))
          operands.push(rhs)
          logic_or_internal(operands)
        }
      }
  }
}

///|
fn logic_equivalent_internal(lhs : LogicExpr, rhs : LogicExpr) -> LogicExpr {
  if lhs == rhs {
    return Bool(true)
  }
  let operands = Array::new(capacity=2)
  operands.push(lhs)
  operands.push(rhs)
  let xor_expr = logic_xor_internal(operands)
  logic_not_canonical(xor_expr)
}

///|
fn logic_ite_internal(
  condition : LogicExpr,
  then_branch : LogicExpr,
  else_branch : LogicExpr,
) -> LogicExpr {
  match condition {
    Bool(true) => return then_branch
    Bool(false) => return else_branch
    _ => ()
  }
  if then_branch == else_branch {
    return then_branch
  }
  match (then_branch, else_branch) {
    (Bool(true), Bool(false)) => condition
    (Bool(false), Bool(true)) => logic_not_canonical(condition)
    (Bool(true), other) => {
      let operands = Array::new(capacity=2)
      operands.push(condition.copy())
      operands.push(other)
      logic_or_internal(operands)
    }
    (other, Bool(true)) => {
      let negated = logic_not_canonical(condition.copy())
      let operands = Array::new(capacity=2)
      operands.push(negated)
      operands.push(other)
      logic_or_internal(operands)
    }
    (Bool(false), other) => {
      let negated = logic_not_canonical(condition.copy())
      let operands = Array::new(capacity=2)
      operands.push(negated)
      operands.push(other)
      logic_and_internal(operands)
    }
    (other, Bool(false)) => {
      let operands = Array::new(capacity=2)
      operands.push(condition.copy())
      operands.push(other)
      logic_and_internal(operands)
    }
    (lhs, rhs) => Ite(condition, lhs, rhs)
  }
}

///|
fn logic_signature(expr : LogicExpr) -> String {
  match expr {
    Bool(value) => if value { LOGIC_TRUE_SYMBOL } else { LOGIC_FALSE_SYMBOL }
    Symbol(name) => "sym:" + name
    Not(inner) => unary_signature(LOGIC_NOT_SYMBOL, inner)
    And(terms) => signature_for_list(LOGIC_AND_SYMBOL, terms)
    Or(terms) => signature_for_list(LOGIC_OR_SYMBOL, terms)
    Xor(terms) => signature_for_list(LOGIC_XOR_SYMBOL, terms)
    Ite(condition, then_branch, else_branch) =>
      ternary_signature(LOGIC_ITE_SYMBOL, condition, then_branch, else_branch)
    Implies(lhs, rhs) => binary_signature(LOGIC_IMPLIES_SYMBOL, lhs, rhs)
    Equivalent(lhs, rhs) => binary_signature(LOGIC_EQUIVALENT_SYMBOL, lhs, rhs)
  }
}

///|
fn logic_negation_signature(expr : LogicExpr) -> String {
  match expr {
    Not(inner) => logic_signature(inner)
    other => unary_signature(LOGIC_NOT_SYMBOL, other)
  }
}

///|
fn signature_for_list(tag : String, terms : Array[LogicExpr]) -> String {
  let builder = StringBuilder::new()
  builder.write_string(tag)
  builder.write_char('(')
  let parts = collect_signatures(terms)
  let sorted = sort_strings(parts)
  let len = sorted.length()
  for i in 0..<len {
    if i > 0 {
      builder.write_char(',')
    }
    builder.write_string(sorted[i])
  }
  builder.write_char(')')
  builder.to_string()
}

///|
fn binary_signature(tag : String, lhs : LogicExpr, rhs : LogicExpr) -> String {
  let builder = StringBuilder::new()
  builder.write_string(tag)
  builder.write_char('(')
  builder.write_string(logic_signature(lhs))
  builder.write_char(',')
  builder.write_string(logic_signature(rhs))
  builder.write_char(')')
  builder.to_string()
}

///|
fn unary_signature(tag : String, expr : LogicExpr) -> String {
  let builder = StringBuilder::new()
  builder.write_string(tag)
  builder.write_char('(')
  builder.write_string(logic_signature(expr))
  builder.write_char(')')
  builder.to_string()
}

///|
fn ternary_signature(
  tag : String,
  first : LogicExpr,
  second : LogicExpr,
  third : LogicExpr,
) -> String {
  let builder = StringBuilder::new()
  builder.write_string(tag)
  builder.write_char('(')
  builder.write_string(logic_signature(first))
  builder.write_char(',')
  builder.write_string(logic_signature(second))
  builder.write_char(',')
  builder.write_string(logic_signature(third))
  builder.write_char(')')
  builder.to_string()
}

///|
fn collect_signatures(terms : Array[LogicExpr]) -> Array[String] {
  let len = terms.length()
  let collected = Array::new(capacity=len)
  for term in terms {
    collected.push(logic_signature(term))
  }
  collected
}

///|
fn sort_strings(values : Array[String]) -> Array[String] {
  let len = values.length()
  let mut i = 0
  while i < len {
    let mut min_index = i
    let mut j = i + 1
    while j < len {
      if values[j] < values[min_index] {
        min_index = j
      }
      j += 1
    }
    if min_index != i {
      let temp = values[i]
      values[i] = values[min_index]
      values[min_index] = temp
    }
    i += 1
  }
  values
}

///|
fn sort_terms_by_signature(terms : Array[LogicExpr]) -> Array[LogicExpr] {
  let len = terms.length()
  if len <= 1 {
    return terms
  }
  let signatures = Array::new(capacity=len)
  let expressions = Array::new(capacity=len)
  for term in terms {
    signatures.push(logic_signature(term.copy()))
    expressions.push(term)
  }
  let mut i = 0
  while i < len {
    let mut min_index = i
    let mut j = i + 1
    while j < len {
      if signatures[j] < signatures[min_index] {
        min_index = j
      }
      j += 1
    }
    if min_index != i {
      let temp_sig = signatures[i]
      signatures[i] = signatures[min_index]
      signatures[min_index] = temp_sig
      let temp_expr = expressions[i]
      expressions[i] = expressions[min_index]
      expressions[min_index] = temp_expr
    }
    i += 1
  }
  expressions
}
