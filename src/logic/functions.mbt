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
