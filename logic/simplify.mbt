///|
pub fn logic_simplify(expr : LogicExpr) -> LogicExpr {
  logic_normalize(expr)
}

///|
pub fn logic_simplify_with_assignments(
  expr : LogicExpr,
  assignments : Array[(String, Bool)],
) -> LogicExpr {
  let substituted = substitute_assignments(expr, assignments)
  logic_normalize(substituted)
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
    Not(inner) => logic_not(substitute_assignments(inner, assignments))
    And(terms) => {
      let replaced = substitute_term_list(terms, assignments)
      logic_and(replaced)
    }
    Or(terms) => {
      let replaced = substitute_term_list(terms, assignments)
      logic_or(replaced)
    }
    Xor(terms) => {
      let replaced = substitute_term_list(terms, assignments)
      logic_xor(replaced)
    }
    Implies(lhs, rhs) => {
      let next_lhs = substitute_assignments(lhs, assignments)
      let next_rhs = substitute_assignments(rhs, assignments)
      logic_implies(next_lhs, next_rhs)
    }
    Equivalent(lhs, rhs) => {
      let next_lhs = substitute_assignments(lhs, assignments)
      let next_rhs = substitute_assignments(rhs, assignments)
      logic_equivalent(next_lhs, next_rhs)
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
