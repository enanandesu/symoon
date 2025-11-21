///|
pub enum FOTerm {
  Variable(String)
  Constant(String)
} derive(Show, Eq)

///|
pub fn FOTerm::copy(self : FOTerm) -> FOTerm {
  match self {
    Variable(name) => Variable(name)
    Constant(name) => Constant(name)
  }
}

///|
pub enum FOFormula {
  Bool(Bool)
  Predicate(String, Array[FOTerm])
  Not(FOFormula)
  And(Array[FOFormula])
  Or(Array[FOFormula])
  Implies(FOFormula, FOFormula)
  Equivalent(FOFormula, FOFormula)
  ForAll(String, FOFormula)
  Exists(String, FOFormula)
} derive(Show, Eq)

///|
pub fn FOFormula::copy(self : FOFormula) -> FOFormula {
  match self {
    Bool(value) => Bool(value)
    Predicate(name, terms) => {
      let copied_terms = fo_copy_terms(terms)
      Predicate(name, copied_terms)
    }
    Not(inner) => Not(inner.copy())
    And(terms) => And(fo_copy_formulas(terms))
    Or(terms) => Or(fo_copy_formulas(terms))
    Implies(lhs, rhs) => Implies(lhs.copy(), rhs.copy())
    Equivalent(lhs, rhs) => Equivalent(lhs.copy(), rhs.copy())
    ForAll(variable, body) => ForAll(variable, body.copy())
    Exists(variable, body) => Exists(variable, body.copy())
  }
}

///|
fn fo_copy_terms(terms : Array[FOTerm]) -> Array[FOTerm] {
  let len = terms.length()
  let copied = Array::new(capacity=len)
  for term in terms {
    copied.push(term.copy())
  }
  copied
}

///|
fn fo_copy_formulas(terms : Array[FOFormula]) -> Array[FOFormula] {
  let len = terms.length()
  let copied = Array::new(capacity=len)
  for term in terms {
    copied.push(term.copy())
  }
  copied
}

///|
pub struct FOPredicate {
  arity : Int
  evaluator : (Array[String]) -> Bool
}

///|
pub struct FOInterpretation {
  domain : Array[String]
  predicates : Map[String, FOPredicate]
}

///|
pub fn fo_var(name : String) -> FOTerm {
  Variable(name)
}

///|
pub fn fo_const(name : String) -> FOTerm {
  Constant(name)
}

///|
pub fn fo_predicate(arity : Int, evaluator : (Array[String]) -> Bool) -> FOPredicate {
  { arity: arity, evaluator: evaluator }
}

///|
pub fn FOPredicate::evaluate(self : FOPredicate, args : Array[String]) -> Bool {
  (self.evaluator)(args)
}

///|
pub fn fo_interpretation(domain : Array[String]) -> FOInterpretation {
  { domain: domain, predicates: {} }
}

///|
pub fn FOInterpretation::with_predicate(
  self : FOInterpretation,
  name : String,
  predicate : FOPredicate,
) -> FOInterpretation {
  let registry = self.predicates
  registry.set(name, predicate)
  { domain: self.domain, predicates: registry }
}

///|
pub fn FOInterpretation::copy(self : FOInterpretation) -> FOInterpretation {
  let copied_domain = self.domain
  let copied_predicates : Map[String, FOPredicate] = {}
  for entry in self.predicates {
    let (key, predicate) = entry
    copied_predicates.set(key, predicate)
  }
  { domain: copied_domain, predicates: copied_predicates }
}

///|
pub fn fo_eval(formula : FOFormula, interpretation : FOInterpretation) -> Bool? {
  let assignments : Array[(String, String)] = Array::new()
  fo_eval_with_assignments(formula, interpretation, assignments)
}

///|
pub fn fo_eval_with_assignments(
  formula : FOFormula,
  interpretation : FOInterpretation,
  assignments : Array[(String, String)],
) -> Bool? {
  fo_eval_internal(formula, interpretation, assignments)
}

///|
fn fo_eval_internal(
  formula : FOFormula,
  interpretation : FOInterpretation,
  assignments : Array[(String, String)],
) -> Bool? {
  match formula {
    Bool(value) => Some(value)
    Predicate(name, terms) =>
      fo_eval_predicate(name, terms, interpretation, assignments)
    Not(inner) =>
      match fo_eval_internal(inner, interpretation, assignments) {
        Some(value) => Some(!value)
        None => None
      }
    And(terms) => {
      let len = terms.length()
      let mut unknown = false
      for i in 0..<len {
        match fo_eval_internal(terms[i], interpretation, assignments) {
          Some(true) => continue
          Some(false) => return Some(false)
          None => unknown = true
        }
      }
      if unknown {
        None
      } else {
        Some(true)
      }
    }
    Or(terms) => {
      let len = terms.length()
      let mut unknown = false
      for i in 0..<len {
        match fo_eval_internal(terms[i], interpretation, assignments) {
          Some(true) => return Some(true)
          Some(false) => continue
          None => unknown = true
        }
      }
      if unknown {
        None
      } else {
        Some(false)
      }
    }
    Implies(lhs, rhs) => {
      let left_value = fo_eval_internal(lhs, interpretation, assignments)
      let right_value = fo_eval_internal(rhs, interpretation, assignments)
      match (left_value, right_value) {
        (Some(true), Some(result)) => Some(result)
        (Some(false), _) => Some(true)
        (None, Some(true)) => Some(true)
        (None, Some(false)) => None
        (None, None) => None
        (Some(true), None) => None
      }
    }
    Equivalent(lhs, rhs) => {
      let left_value = fo_eval_internal(lhs, interpretation, assignments)
      let right_value = fo_eval_internal(rhs, interpretation, assignments)
      match (left_value, right_value) {
        (Some(l), Some(r)) => Some(l == r)
        _ => None
      }
    }
    ForAll(variable, body) => {
      let len = interpretation.domain.length()
      if len == 0 {
        return Some(true)
      }
      let mut unknown = false
      for i in 0..<len {
        let value = interpretation.domain[i]
        let extended = fo_assignment_set(assignments, variable, value)
        match fo_eval_internal(body, interpretation, extended) {
          Some(true) => continue
          Some(false) => return Some(false)
          None => unknown = true
        }
      }
      if unknown {
        None
      } else {
        Some(true)
      }
    }
    Exists(variable, body) => {
      let len = interpretation.domain.length()
      if len == 0 {
        return Some(false)
      }
      let mut unknown = false
      for i in 0..<len {
        let value = interpretation.domain[i]
        let extended = fo_assignment_set(assignments, variable, value)
        match fo_eval_internal(body, interpretation, extended) {
          Some(true) => return Some(true)
          Some(false) => continue
          None => unknown = true
        }
      }
      if unknown {
        None
      } else {
        Some(false)
      }
    }
  }
}

///|
fn fo_eval_predicate(
  name : String,
  terms : Array[FOTerm],
  interpretation : FOInterpretation,
  assignments : Array[(String, String)],
) -> Bool? {
  match interpretation.predicates.get(name) {
    Some(predicate) => {
      if predicate.arity != terms.length() {
        abort("predicate arity mismatch: " + name)
      }
      let args = Array::new(capacity=predicate.arity)
      for term in terms {
        match fo_eval_term(term, assignments) {
          Some(value) => args.push(value)
          None => return None
        }
      }
      Some(predicate.evaluate(args))
    }
    None => abort("predicate not registered: " + name)
  }
}

///|
fn fo_eval_term(term : FOTerm, assignments : Array[(String, String)]) -> String? {
  match term {
    Variable(name) => fo_assignment_lookup(assignments, name)
    Constant(value) => Some(value)
  }
}

///|
fn fo_assignment_lookup(
  assignments : Array[(String, String)],
  name : String,
) -> String? {
  let len = assignments.length()
  for i in 0..<len {
    let (key, value) = assignments[i]
    if key == name {
      return Some(value)
    }
  }
  None
}

///|
fn fo_assignment_set(
  assignments : Array[(String, String)],
  name : String,
  value : String,
) -> Array[(String, String)] {
  let len = assignments.length()
  let updated = Array::new()
  let mut replaced = false
  for i in 0..<len {
    let (key, existing) = assignments[i]
    if key == name {
      updated.push((key, value))
      replaced = true
    } else {
      updated.push((key, existing))
    }
  }
  if !replaced {
    updated.push((name, value))
  }
  updated
}
