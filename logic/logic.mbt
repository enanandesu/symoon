///|
pub enum LogicExpr {
  Bool(Bool)
  Symbol(String)
  Not(LogicExpr)
  And(Array[LogicExpr])
  Or(Array[LogicExpr])
  Xor(Array[LogicExpr])
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
pub fn logic_eval(
  expr : LogicExpr,
  assignments : Array[(String, Bool)],
) -> Bool? {
  let (_, result) = logic_eval_internal(logic_normalize(expr), assignments)
  result
}

///|

///|
fn logic_eval_internal(
  expr : LogicExpr,
  assignments : Array[(String, Bool)],
) -> (Array[(String, Bool)], Bool?) {
  match expr {
    Bool(value) => (assignments, Some(value))
    Symbol(name) => lookup_assignment(assignments, name)
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
  }
}

///|
fn lookup_assignment(
  assignments : Array[(String, Bool)],
  name : String,
) -> (Array[(String, Bool)], Bool?) {
  let len = assignments.length()
  for i in 0..<len {
    let (key, value) = assignments[i]
    if key == name {
      return (assignments, Some(value))
    }
  }
  (assignments, None)
}
