///|
pub enum LogicSatResult {
  Unsatisfiable
  Model(Array[(String, Bool)])
  AllModels(Array[Array[(String, Bool)]])
} derive(Show, Eq)

///|
pub fn logic_from_truth_table(
  variables : Array[String],
  rows : Array[(Array[Bool], Bool)],
) -> LogicExpr {
  let variable_count = variables.length()
  if variable_count == 0 {
    for row in rows {
      let (_, value) = row
      if value {
        return logic_true()
      }
    }
    return logic_false()
  }
  let canonical_symbols = Array::new(capacity=variable_count)
  for name in variables {
    canonical_symbols.push(logic_symbol(name))
  }
  let true_clauses = Array::new()
  for row in rows {
    let (assignment, result) = row
    if assignment.length() != variable_count {
      abort("truth table row length mismatch")
    }
    if !result {
      continue
    }
    let conjunction = Array::new(capacity=variable_count)
    for i in 0..<variable_count {
      let base_symbol = canonical_symbols[i].copy()
      if assignment[i] {
        conjunction.push(base_symbol)
      } else {
        conjunction.push(logic_not(base_symbol))
      }
    }
    true_clauses.push(logic_and(conjunction))
  }
  if true_clauses.length() == 0 {
    logic_false()
  } else if true_clauses.length() == 1 {
    true_clauses[0]
  } else {
    logic_or(true_clauses)
  }
}

///|
pub fn logic_truth_table(
  expr : LogicExpr,
  variables : Array[String],
) -> Array[(Array[Bool], Bool?)] {
  let normalized = logic_normalize(expr)
  let variable_count = variables.length()
  let total = truth_pow_two(variable_count)
  let rows = Array::new(capacity=total)
  let mut index = 0
  while index < total {
    let assignment = truth_assignment_from_index(index, variable_count)
    let env = Array::new(capacity=variable_count)
    let mut i = 0
    while i < variable_count {
      env.push((variables[i], assignment[i]))
      i += 1
    }
    let value = logic_eval(normalized.copy(), env)
    rows.push((assignment, value))
    index += 1
  }
  rows
}

///|
pub fn logic_truth_table_lines(
  expr : LogicExpr,
  variables : Array[String],
) -> Array[String] {
  let rows = logic_truth_table(expr, variables)
  let lines = Array::new(capacity=rows.length())
  for row in rows {
    let (inputs, result) = row
    let input_str = format_bool_list(inputs)
    let output_str = match result {
      Some(true) => "true"
      Some(false) => "false"
      None => "unknown"
    }
    lines.push(input_str + " -> " + output_str)
  }
  lines
}

///|
fn truth_pow_two(exp : Int) -> Int {
  let mut value = 1
  let mut i = 0
  while i < exp {
    value = value * 2
    i += 1
  }
  value
}

///|
fn truth_assignment_from_index(index : Int, count : Int) -> Array[Bool] {
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
fn format_bool_list(values : Array[Bool]) -> String {
  let builder = StringBuilder::new()
  builder.write_char('[')
  let len = values.length()
  let mut i = 0
  while i < len {
    if i > 0 {
      builder.write_string(", ")
    }
    builder.write_string(if values[i] { "true" } else { "false" })
    i += 1
  }
  builder.write_char(']')
  builder.to_string()
}

///|
pub fn logic_distribute_and_over_or(expr : LogicExpr) -> LogicExpr {
  distribute_and_over_or_internal(logic_normalize(expr))
}

///|
fn distribute_and_over_or_internal(expr : LogicExpr) -> LogicExpr {
  match expr {
    And(terms) => distribute_and_terms(terms)
    Or(terms) => {
      let distributed = map_terms(terms, distribute_and_over_or_internal)
      logic_or(distributed)
    }
    Not(inner) => logic_not(distribute_and_over_or_internal(inner))
    Ite(cond, then_branch, else_branch) =>
      logic_ite(
        distribute_and_over_or_internal(cond),
        distribute_and_over_or_internal(then_branch),
        distribute_and_over_or_internal(else_branch),
      )
    Implies(lhs, rhs) =>
      logic_implies(
        distribute_and_over_or_internal(lhs),
        distribute_and_over_or_internal(rhs),
      )
    Equivalent(lhs, rhs) =>
      logic_equivalent(
        distribute_and_over_or_internal(lhs),
        distribute_and_over_or_internal(rhs),
      )
    other => other
  }
}

///|
fn distribute_and_terms(terms : Array[LogicExpr]) -> LogicExpr {
  let processed = map_terms(terms, distribute_and_over_or_internal)
  let len = processed.length()
  let mut i = 0
  while i < len {
    match processed[i] {
      Or(options) => {
        let expanded = Array::new(capacity=options.length())
        let prefix = slice_terms(processed, 0, i)
        let suffix = slice_terms(processed, i + 1, len)
        let opt_len = options.length()
        let mut j = 0
        while j < opt_len {
          let new_terms = Array::new()
          push_terms(new_terms, prefix)
          new_terms.push(options[j].copy())
          push_terms(new_terms, suffix)
          expanded.push(distribute_and_over_or_internal(logic_and(new_terms)))
          j += 1
        }
        return logic_or(expanded)
      }
      _ => ()
    }
    i += 1
  }
  logic_and(processed)
}

///|
pub fn logic_distribute_or_over_and(expr : LogicExpr) -> LogicExpr {
  distribute_or_over_and_internal(logic_normalize(expr))
}

///|
fn distribute_or_over_and_internal(expr : LogicExpr) -> LogicExpr {
  match expr {
    Or(terms) => distribute_or_terms(terms)
    And(terms) => {
      let distributed = map_terms(terms, distribute_or_over_and_internal)
      logic_and(distributed)
    }
    Not(inner) => logic_not(distribute_or_over_and_internal(inner))
    Ite(cond, then_branch, else_branch) =>
      logic_ite(
        distribute_or_over_and_internal(cond),
        distribute_or_over_and_internal(then_branch),
        distribute_or_over_and_internal(else_branch),
      )
    Implies(lhs, rhs) =>
      logic_implies(
        distribute_or_over_and_internal(lhs),
        distribute_or_over_and_internal(rhs),
      )
    Equivalent(lhs, rhs) =>
      logic_equivalent(
        distribute_or_over_and_internal(lhs),
        distribute_or_over_and_internal(rhs),
      )
    other => other
  }
}

///|
fn distribute_or_terms(terms : Array[LogicExpr]) -> LogicExpr {
  let processed = map_terms(terms, distribute_or_over_and_internal)
  let len = processed.length()
  let mut i = 0
  while i < len {
    match processed[i] {
      And(options) => {
        let expanded = Array::new(capacity=options.length())
        let prefix = slice_terms(processed, 0, i)
        let suffix = slice_terms(processed, i + 1, len)
        let opt_len = options.length()
        let mut j = 0
        while j < opt_len {
          let new_terms = Array::new()
          push_terms(new_terms, prefix)
          new_terms.push(options[j].copy())
          push_terms(new_terms, suffix)
          expanded.push(distribute_or_over_and_internal(logic_or(new_terms)))
          j += 1
        }
        return logic_and(expanded)
      }
      _ => ()
    }
    i += 1
  }
  logic_or(processed)
}

///|
fn map_terms(
  terms : Array[LogicExpr],
  mapper : (LogicExpr) -> LogicExpr,
) -> Array[LogicExpr] {
  let len = terms.length()
  let mapped = Array::new(capacity=len)
  let mut i = 0
  while i < len {
    mapped.push(mapper(terms[i]))
    i += 1
  }
  mapped
}

///|
fn slice_terms(
  terms : Array[LogicExpr],
  start : Int,
  end : Int,
) -> Array[LogicExpr] {
  let sliced = Array::new()
  let mut i = start
  while i < end {
    sliced.push(terms[i].copy())
    i += 1
  }
  sliced
}

///|
fn push_terms(target : Array[LogicExpr], source : Array[LogicExpr]) -> Unit {
  let len = source.length()
  let mut i = 0
  while i < len {
    target.push(source[i])
    i += 1
  }
}

///|
pub fn logic_probability(
  expr : LogicExpr,
  probabilities : Array[(String, Double)],
) -> Double {
  let normalized = logic_normalize(expr)
  logic_probability_internal(normalized, probabilities)
}

///|
pub fn logic_conditional_probability(
  expr : LogicExpr,
  given : LogicExpr,
  probabilities : Array[(String, Double)],
) -> Double {
  let joint = logic_probability(
    logic_and([expr.copy(), given.copy()]),
    probabilities,
  )
  let given_prob = logic_probability(given, probabilities)
  if given_prob == 0.0 {
    abort("conditional probability undefined when given probability is zero")
  }
  joint / given_prob
}

///|
pub fn logic_gate_model() -> LogicExpr {
  let a = logic_symbol("A")
  let b = logic_symbol("B")
  let c = logic_symbol("C")
  let and_gate = logic_and([a.copy(), b.copy()])
  let or_gate = logic_or([b.copy(), c.copy()])
  let not_gate = logic_not(c)
  logic_and([and_gate, logic_or([or_gate, not_gate])])
}

///|
pub fn logic_half_adder(a : LogicExpr, b : LogicExpr) -> (LogicExpr, LogicExpr) {
  let sum_bit = logic_xor([a.copy(), b.copy()])
  let carry_bit = logic_and([a, b])
  (sum_bit, carry_bit)
}

///|
pub fn logic_full_adder(
  a : LogicExpr,
  b : LogicExpr,
  carry_in : LogicExpr,
) -> (LogicExpr, LogicExpr) {
  let (sum1, carry1) = logic_half_adder(a.copy(), b.copy())
  let (sum_out, carry2) = logic_half_adder(sum1.copy(), carry_in)
  let carry_out = logic_or([carry1, carry2])
  (sum_out, carry_out)
}

///|
fn logic_probability_internal(
  expr : LogicExpr,
  probabilities : Array[(String, Double)],
) -> Double {
  match expr {
    Bool(true) => 1.0
    Bool(false) => 0.0
    Symbol(name) => lookup_probability(probabilities, name)
    Not(inner) => 1.0 - logic_probability_internal(inner, probabilities)
    And(terms) => probability_and_terms(terms, probabilities)
    Or(terms) => probability_or_terms(terms, probabilities)
    Xor(terms) => probability_xor_terms(terms, probabilities)
    Implies(lhs, rhs) => {
      let p_lhs = logic_probability_internal(lhs.copy(), probabilities)
      let p_rhs = logic_probability_internal(rhs.copy(), probabilities)
      1.0 - p_lhs * (1.0 - p_rhs)
    }
    Equivalent(lhs, rhs) => {
      let xor_prob = probability_xor_terms([lhs, rhs], probabilities)
      1.0 - xor_prob
    }
    Ite(condition, then_branch, else_branch) => {
      let p_cond = logic_probability_internal(condition.copy(), probabilities)
      let p_then = logic_probability_internal(then_branch.copy(), probabilities)
      let p_else = logic_probability_internal(else_branch.copy(), probabilities)
      p_cond * p_then + (1.0 - p_cond) * p_else
    }
  }
}

///|
fn probability_and_terms(
  terms : Array[LogicExpr],
  probabilities : Array[(String, Double)],
) -> Double {
  let len = terms.length()
  if len == 0 {
    return 1.0
  }
  let mut product : Double = 1.0
  let mut i = 0
  while i < len {
    product = product * logic_probability_internal(terms[i], probabilities)
    i += 1
  }
  product
}

///|
fn probability_or_terms(
  terms : Array[LogicExpr],
  probabilities : Array[(String, Double)],
) -> Double {
  let len = terms.length()
  if len == 0 {
    return 0.0
  }
  let mut complement_product : Double = 1.0
  let mut i = 0
  while i < len {
    let p = logic_probability_internal(terms[i], probabilities)
    complement_product = complement_product * (1.0 - p)
    i += 1
  }
  1.0 - complement_product
}

///|
fn probability_xor_terms(
  terms : Array[LogicExpr],
  probabilities : Array[(String, Double)],
) -> Double {
  let len = terms.length()
  if len == 0 {
    return 0.0
  }
  let mut parity_prob : Double = 0.0
  let mut i = 0
  while i < len {
    let p = logic_probability_internal(terms[i], probabilities)
    parity_prob = parity_prob * (1.0 - p) + (1.0 - parity_prob) * p
    i += 1
  }
  parity_prob
}

///|
fn lookup_probability(
  probabilities : Array[(String, Double)],
  name : String,
) -> Double {
  let len = probabilities.length()
  let mut i = 0
  while i < len {
    let (key, value) = probabilities[i]
    if key == name {
      return value
    }
    i += 1
  }
  abort("missing probability for symbol: " + name)
}

///|
pub fn logic_satisfiable(
  expr : LogicExpr,
  all_models? : Bool = false,
  variables? : Array[String] = Array::new(),
) -> LogicSatResult {
  let normalized = logic_normalize(expr)
  let variable_list = resolve_variable_list(normalized.copy(), variables)
  if all_models {
    let models = collect_all_models(normalized, variable_list)
    if models.length() == 0 {
      LogicSatResult::Unsatisfiable
    } else {
      LogicSatResult::AllModels(models)
    }
  } else {
    match find_first_model(normalized, variable_list) {
      Some(model) => LogicSatResult::Model(model)
      None => LogicSatResult::Unsatisfiable
    }
  }
}

///|
pub fn logic_all_satisfying_assignments(
  expr : LogicExpr,
  variables? : Array[String] = Array::new(),
) -> Array[Array[(String, Bool)]] {
  let normalized = logic_normalize(expr)
  let variable_list = resolve_variable_list(normalized.copy(), variables)
  collect_all_models(normalized, variable_list)
}

///|
pub fn logic_is_tautology(
  expr : LogicExpr,
  variables? : Array[String] = Array::new(),
) -> Bool {
  match logic_satisfiable(logic_not(expr), variables~) {
    LogicSatResult::Unsatisfiable => true
    _ => false
  }
}

///|
pub fn logic_equivalent_expr(
  lhs : LogicExpr,
  rhs : LogicExpr,
  variables? : Array[String] = Array::new(),
) -> Bool {
  logic_is_tautology(logic_equivalent(lhs, rhs), variables~)
}

///|
fn satisfiable_search(
  expr : LogicExpr,
  variables : Array[String],
  index : Int,
  env : Array[(String, Bool)],
) -> Array[(String, Bool)]? {
  if index == variables.length() {
    match logic_eval(expr.copy(), env) {
      Some(true) => Some(env)
      _ => None
    }
  } else {
    let name = variables[index]
    let next_index = index + 1
    let with_true = extend_env(env, name, true)
    match satisfiable_search(expr, variables, next_index, with_true) {
      Some(solution) => Some(solution)
      None => {
        let with_false = extend_env(env, name, false)
        satisfiable_search(expr, variables, next_index, with_false)
      }
    }
  }
}

///|
fn collect_solutions(
  expr : LogicExpr,
  variables : Array[String],
  index : Int,
  env : Array[(String, Bool)],
  results : Array[Array[(String, Bool)]],
) -> Array[Array[(String, Bool)]] {
  if index == variables.length() {
    match logic_eval(expr.copy(), env) {
      Some(true) => results.push(env)
      _ => ()
    }
    return results
  }
  let name = variables[index]
  let next_index = index + 1
  let with_true = extend_env(env, name, true)
  let _ = collect_solutions(expr, variables, next_index, with_true, results)
  let with_false = extend_env(env, name, false)
  collect_solutions(expr, variables, next_index, with_false, results)
}

///|
fn resolve_variable_list(
  expr : LogicExpr,
  variables : Array[String],
) -> Array[String] {
  if variables.length() == 0 {
    logic_collect_variables(expr)
  } else {
    variables
  }
}

///|
fn collect_all_models(
  expr : LogicExpr,
  variables : Array[String],
) -> Array[Array[(String, Bool)]] {
  let results = Array::new()
  let empty_env : Array[(String, Bool)] = Array::new()
  collect_solutions(expr, variables, 0, empty_env, results)
}

///|
fn find_first_model(
  expr : LogicExpr,
  variables : Array[String],
) -> Array[(String, Bool)]? {
  let empty_env : Array[(String, Bool)] = Array::new()
  satisfiable_search(expr, variables, 0, empty_env)
}

///|
fn extend_env(
  env : Array[(String, Bool)],
  name : String,
  value : Bool,
) -> Array[(String, Bool)] {
  let next = Array::new()
  for pair in env {
    next.push(pair)
  }
  next.push((name, value))
  next
}
