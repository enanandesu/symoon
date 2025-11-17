///|
pub fn logic_apply_assignments(
  expr : LogicExpr,
  assignments : Array[(String, Bool)],
) -> LogicExpr {
  let normalized = logic_normalize(expr)
  substitute_assignments(normalized, assignments)
}

///|
pub fn logic_apply_and_eval(
  expr : LogicExpr,
  assignments : Array[(String, Bool)],
) -> (LogicExpr, Bool?) {
  let applied = logic_apply_assignments(expr, assignments)
  let empty_env : Array[(String, Bool)] = Array::new()
  let value = logic_eval(applied.copy(), empty_env)
  (applied, value)
}

///|
fn substitute_assignments(
  expr : LogicExpr,
  assignments : Array[(String, Bool)],
) -> LogicExpr {
  match expr {
    Bool(_) => expr
    Symbol(name) =>
      match lookup_assignment_value(assignments, name) {
        Some(value) => Bool(value)
        None => Symbol(name)
      }
    Not(inner) =>
      logic_normalize(
        LogicExpr::Not(substitute_assignments(inner, assignments)),
      )
    And(terms) => {
      let replaced = substitute_term_list(terms, assignments)
      logic_normalize(LogicExpr::And(replaced))
    }
    Or(terms) => {
      let replaced = substitute_term_list(terms, assignments)
      logic_normalize(LogicExpr::Or(replaced))
    }
    Xor(terms) => {
      let replaced = substitute_term_list(terms, assignments)
      logic_normalize(LogicExpr::Xor(replaced))
    }
    Implies(lhs, rhs) => {
      let next_lhs = substitute_assignments(lhs, assignments)
      let next_rhs = substitute_assignments(rhs, assignments)
      logic_normalize(LogicExpr::Implies(next_lhs, next_rhs))
    }
    Equivalent(lhs, rhs) => {
      let next_lhs = substitute_assignments(lhs, assignments)
      let next_rhs = substitute_assignments(rhs, assignments)
      logic_normalize(LogicExpr::Equivalent(next_lhs, next_rhs))
    }
  }
}

///|
fn substitute_term_list(
  terms : Array[LogicExpr],
  assignments : Array[(String, Bool)],
) -> Array[LogicExpr] {
  let len = terms.length()
  let replaced = Array::new(capacity=len)
  for term in terms {
    replaced.push(substitute_assignments(term, assignments))
  }
  replaced
}

///|
fn lookup_assignment_value(
  assignments : Array[(String, Bool)],
  name : String,
) -> Bool? {
  let len = assignments.length()
  for i in 0..<len {
    let (key, value) = assignments[i]
    if key == name {
      return Some(value)
    }
  }
  None
}
