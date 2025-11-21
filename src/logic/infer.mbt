///|
pub fn logic_infer(premises : Array[LogicExpr], conclusion : LogicExpr) -> Bool {
  let normalized_premises = normalize_operands(premises)
  let normalized_conclusion = logic_normalize(conclusion)
  let mut seen_symbols : Map[String, Bool] = {}
  let mut symbols = Array::new()
  let premise_len = normalized_premises.length()
  for i in 0..<premise_len {
    let (next_seen, next_symbols) = collect_logic_symbols(
      normalized_premises[i],
      seen_symbols,
      symbols,
    )
    seen_symbols = next_seen
    symbols = next_symbols
  }
  let (_, complete_symbols) = collect_logic_symbols(
    normalized_conclusion, seen_symbols, symbols,
  )
  let sorted = sort_strings(complete_symbols)
  let empty_assignments : Array[(String, Bool)] = Array::new()
  inference_enumerate(
    normalized_premises, normalized_conclusion, sorted, 0, empty_assignments,
  )
}

///|
fn collect_logic_symbols(
  expr : LogicExpr,
  seen : Map[String, Bool],
  symbols : Array[String],
) -> (Map[String, Bool], Array[String]) {
  match expr {
    Bool(_) => (seen, symbols)
    Symbol(name) => register_logic_symbol(name, seen, symbols)
    Not(inner) => collect_logic_symbols(inner, seen, symbols)
    And(terms) => collect_symbols_from_terms(terms, seen, symbols)
    Or(terms) => collect_symbols_from_terms(terms, seen, symbols)
    Xor(terms) => collect_symbols_from_terms(terms, seen, symbols)
    Ite(condition, then_branch, else_branch) => {
      let (after_condition, after_condition_symbols) = collect_logic_symbols(
        condition, seen, symbols,
      )
      let (after_then, after_then_symbols) = collect_logic_symbols(
        then_branch, after_condition, after_condition_symbols,
      )
      collect_logic_symbols(else_branch, after_then, after_then_symbols)
    }
    Implies(lhs, rhs) => {
      let (after_lhs, names_after_lhs) = collect_logic_symbols(
        lhs, seen, symbols,
      )
      collect_logic_symbols(rhs, after_lhs, names_after_lhs)
    }
    Equivalent(lhs, rhs) => {
      let (after_lhs, names_after_lhs) = collect_logic_symbols(
        lhs, seen, symbols,
      )
      collect_logic_symbols(rhs, after_lhs, names_after_lhs)
    }
  }
}

///|
fn collect_symbols_from_terms(
  terms : Array[LogicExpr],
  seen : Map[String, Bool],
  symbols : Array[String],
) -> (Map[String, Bool], Array[String]) {
  let len = terms.length()
  let mut current_seen = seen
  let mut current_symbols = symbols
  for i in 0..<len {
    let (next_seen, next_symbols) = collect_logic_symbols(
      terms[i],
      current_seen,
      current_symbols,
    )
    current_seen = next_seen
    current_symbols = next_symbols
  }
  (current_seen, current_symbols)
}

///|
fn register_logic_symbol(
  name : String,
  seen : Map[String, Bool],
  symbols : Array[String],
) -> (Map[String, Bool], Array[String]) {
  if seen.contains(name) {
    (seen, symbols)
  } else {
    let updated_seen = seen
    updated_seen.set(name, true)
    let updated_symbols = symbols
    updated_symbols.push(name)
    (updated_seen, updated_symbols)
  }
}

///|
fn inference_enumerate(
  premises : Array[LogicExpr],
  conclusion : LogicExpr,
  symbols : Array[String],
  index : Int,
  assignments : Array[(String, Bool)],
) -> Bool {
  if index == symbols.length() {
    return inference_check_assignment(premises, conclusion, assignments)
  }
  let name = symbols[index]
  let next_index = index + 1
  let with_true = extend_assignments(assignments, name, true)
  if !inference_enumerate(premises, conclusion, symbols, next_index, with_true) {
    return false
  }
  let with_false = extend_assignments(assignments, name, false)
  inference_enumerate(premises, conclusion, symbols, next_index, with_false)
}

///|
fn inference_check_assignment(
  premises : Array[LogicExpr],
  conclusion : LogicExpr,
  assignments : Array[(String, Bool)],
) -> Bool {
  let len = premises.length()
  for i in 0..<len {
    match logic_eval(premises[i].copy(), assignments) {
      Some(true) => continue
      Some(false) => return true
      None => return false
    }
  }
  match logic_eval(conclusion.copy(), assignments) {
    Some(true) => true
    _ => false
  }
}

///|
fn extend_assignments(
  existing : Array[(String, Bool)],
  name : String,
  value : Bool,
) -> Array[(String, Bool)] {
  let extended = Array::new()
  let len = existing.length()
  for i in 0..<len {
    extended.push(existing[i])
  }
  extended.push((name, value))
  extended
}
