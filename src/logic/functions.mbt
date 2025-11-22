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
pub fn logic_satisfiable(expr : LogicExpr) -> Array[(String, Bool)]? {
  let normalized = logic_normalize(expr)
  let variables = logic_collect_variables(normalized.copy())
  let empty_env : Array[(String, Bool)] = Array::new()
  satisfiable_search(normalized, variables, 0, empty_env)
}

///|
pub fn logic_all_satisfying_assignments(
  expr : LogicExpr,
  variables? : Array[String] = Array::new(),
) -> Array[Array[(String, Bool)]] {
  let normalized = logic_normalize(expr)
  let variable_list = if variables.length() == 0 {
    logic_collect_variables(normalized.copy())
  } else {
    variables
  }
  let results = Array::new()
  let empty_env : Array[(String, Bool)] = Array::new()
  collect_solutions(normalized, variable_list, 0, empty_env, results)
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
