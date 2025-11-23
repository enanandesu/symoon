///|
pub enum LTLExpr {
  Bool(Bool)
  Symbol(String)
  Not(LTLExpr)
  And(Array[LTLExpr])
  Or(Array[LTLExpr])
  Next(LTLExpr)
  Until(LTLExpr, LTLExpr)
  Release(LTLExpr, LTLExpr)
  Always(LTLExpr)
  Eventually(LTLExpr)
} derive(Show, Eq)

///|
pub fn LTLExpr::copy(self : LTLExpr) -> LTLExpr {
  match self {
    Bool(value) => Bool(value)
    Symbol(name) => Symbol(name)
    Not(inner) => Not(inner.copy())
    And(terms) => And(ltl_copy_terms(terms))
    Or(terms) => Or(ltl_copy_terms(terms))
    Next(inner) => Next(inner.copy())
    Until(lhs, rhs) => Until(lhs.copy(), rhs.copy())
    Release(lhs, rhs) => Release(lhs.copy(), rhs.copy())
    Always(inner) => Always(inner.copy())
    Eventually(inner) => Eventually(inner.copy())
  }
}

///|
fn ltl_copy_terms(terms : Array[LTLExpr]) -> Array[LTLExpr] {
  let len = terms.length()
  let copied = Array::new(capacity=len)
  for i in 0..<len {
    copied.push(terms[i].copy())
  }
  copied
}

///|
pub fn ltl_symbol(name : String) -> LTLExpr {
  Symbol(name)
}

///|
pub fn ltl_true() -> LTLExpr {
  Bool(true)
}

///|
pub fn ltl_false() -> LTLExpr {
  Bool(false)
}

///|
pub fn ltl_not(expr : LTLExpr) -> LTLExpr {
  ltl_not_canonical(ltl_normalize(expr))
}

///|
pub fn ltl_and(terms : Array[LTLExpr]) -> LTLExpr {
  ltl_and_internal(ltl_normalize_terms(terms))
}

///|
pub fn ltl_or(terms : Array[LTLExpr]) -> LTLExpr {
  ltl_or_internal(ltl_normalize_terms(terms))
}

///|
pub fn ltl_next(expr : LTLExpr) -> LTLExpr {
  Next(ltl_normalize(expr))
}

///|
pub fn ltl_until(lhs : LTLExpr, rhs : LTLExpr) -> LTLExpr {
  Until(ltl_normalize(lhs), ltl_normalize(rhs))
}

///|
pub fn ltl_release(lhs : LTLExpr, rhs : LTLExpr) -> LTLExpr {
  Release(ltl_normalize(lhs), ltl_normalize(rhs))
}

///|
pub fn ltl_always(expr : LTLExpr) -> LTLExpr {
  Always(ltl_normalize(expr))
}

///|
pub fn ltl_eventually(expr : LTLExpr) -> LTLExpr {
  Eventually(ltl_normalize(expr))
}

///|
pub fn ltl_normalize(expr : LTLExpr) -> LTLExpr {
  match expr {
    Bool(_) => expr
    Symbol(_) => expr
    Not(inner) => ltl_not_canonical(ltl_normalize(inner))
    And(terms) => ltl_and_internal(ltl_normalize_terms(terms))
    Or(terms) => ltl_or_internal(ltl_normalize_terms(terms))
    Next(inner) => ltl_next(inner)
    Until(lhs, rhs) => ltl_until(lhs, rhs)
    Release(lhs, rhs) => ltl_release(lhs, rhs)
    Always(inner) => ltl_always(inner)
    Eventually(inner) => ltl_eventually(inner)
  }
}

///|
fn ltl_normalize_terms(terms : Array[LTLExpr]) -> Array[LTLExpr] {
  let len = terms.length()
  let normalized = Array::new(capacity=len)
  for i in 0..<len {
    normalized.push(ltl_normalize(terms[i]))
  }
  normalized
}

///|
fn ltl_not_canonical(expr : LTLExpr) -> LTLExpr {
  match expr {
    Bool(value) => Bool(!value)
    Not(inner) => inner
    _ => Not(expr)
  }
}

///|
fn ltl_and_internal(terms : Array[LTLExpr]) -> LTLExpr {
  if terms.length() == 0 {
    return Bool(true)
  }
  let flat = Array::new()
  let len = terms.length()
  for i in 0..<len {
    match terms[i] {
      Bool(true) => ()
      Bool(false) => return Bool(false)
      And(inner) => push_ltl_terms(flat, inner)
      other => flat.push(other)
    }
  }
  let count = flat.length()
  if count == 0 {
    Bool(true)
  } else if count == 1 {
    flat[0]
  } else {
    And(flat)
  }
}

///|
fn ltl_or_internal(terms : Array[LTLExpr]) -> LTLExpr {
  if terms.length() == 0 {
    return Bool(false)
  }
  let flat = Array::new()
  let len = terms.length()
  for i in 0..<len {
    match terms[i] {
      Bool(true) => return Bool(true)
      Bool(false) => ()
      Or(inner) => push_ltl_terms(flat, inner)
      other => flat.push(other)
    }
  }
  let count = flat.length()
  if count == 0 {
    Bool(false)
  } else if count == 1 {
    flat[0]
  } else {
    Or(flat)
  }
}

///|
fn push_ltl_terms(target : Array[LTLExpr], source : Array[LTLExpr]) -> Unit {
  let len = source.length()
  let mut i = 0
  while i < len {
    target.push(source[i])
    i += 1
  }
}

///|
pub fn ltl_eval(expr : LTLExpr, trace : Array[Array[(String, Bool)]]) -> Bool? {
  ltl_eval_from(ltl_normalize(expr), trace, 0)
}

///|
fn ltl_eval_from(
  expr : LTLExpr,
  trace : Array[Array[(String, Bool)]],
  index : Int,
) -> Bool? {
  match expr {
    Bool(value) => Some(value)
    Symbol(name) => ltl_lookup(trace, index, name)
    Not(inner) =>
      match ltl_eval_from(inner, trace, index) {
        Some(value) => Some(!value)
        None => None
      }
    And(terms) => ltl_eval_and(terms, trace, index)
    Or(terms) => ltl_eval_or(terms, trace, index)
    Next(inner) =>
      if index + 1 >= trace.length() {
        None
      } else {
        ltl_eval_from(inner, trace, index + 1)
      }
    Always(inner) => ltl_eval_always(inner, trace, index)
    Eventually(inner) => ltl_eval_eventually(inner, trace, index)
    Until(lhs, rhs) => ltl_eval_until(lhs, rhs, trace, index)
    Release(lhs, rhs) => ltl_eval_release(lhs, rhs, trace, index)
  }
}

///|
fn ltl_eval_and(
  terms : Array[LTLExpr],
  trace : Array[Array[(String, Bool)]],
  index : Int,
) -> Bool? {
  let len = terms.length()
  let mut unknown = false
  let mut i = 0
  while i < len {
    match ltl_eval_from(terms[i], trace, index) {
      Some(true) => ()
      Some(false) => return Some(false)
      None => unknown = true
    }
    i += 1
  }
  if unknown {
    None
  } else {
    Some(true)
  }
}

///|
fn ltl_eval_or(
  terms : Array[LTLExpr],
  trace : Array[Array[(String, Bool)]],
  index : Int,
) -> Bool? {
  let len = terms.length()
  let mut unknown = false
  let mut i = 0
  while i < len {
    match ltl_eval_from(terms[i], trace, index) {
      Some(true) => return Some(true)
      Some(false) => ()
      None => unknown = true
    }
    i += 1
  }
  if unknown {
    None
  } else {
    Some(false)
  }
}

///|
fn ltl_eval_always(
  expr : LTLExpr,
  trace : Array[Array[(String, Bool)]],
  index : Int,
) -> Bool? {
  let len = trace.length()
  let mut i = index
  let mut unknown = false
  while i < len {
    match ltl_eval_from(expr.copy(), trace, i) {
      Some(true) => ()
      Some(false) => return Some(false)
      None => unknown = true
    }
    i += 1
  }
  if unknown {
    None
  } else {
    Some(true)
  }
}

///|
fn ltl_eval_eventually(
  expr : LTLExpr,
  trace : Array[Array[(String, Bool)]],
  index : Int,
) -> Bool? {
  let len = trace.length()
  let mut i = index
  let mut unknown = false
  while i < len {
    match ltl_eval_from(expr.copy(), trace, i) {
      Some(true) => return Some(true)
      Some(false) => ()
      None => unknown = true
    }
    i += 1
  }
  if unknown {
    None
  } else {
    Some(false)
  }
}

///|
fn ltl_eval_until(
  lhs : LTLExpr,
  rhs : LTLExpr,
  trace : Array[Array[(String, Bool)]],
  index : Int,
) -> Bool? {
  match ltl_eval_from(rhs.copy(), trace, index) {
    Some(true) => return Some(true)
    Some(false) => ()
    None =>
      match ltl_eval_from(lhs.copy(), trace, index) {
        Some(false) => return Some(false)
        Some(true) => return None
        None => return None
      }
  }
  match ltl_eval_from(lhs.copy(), trace, index) {
    Some(false) => Some(false)
    Some(true) =>
      if index + 1 >= trace.length() {
        None
      } else {
        ltl_eval_until(lhs, rhs, trace, index + 1)
      }
    None => None
  }
}

///|
fn ltl_eval_release(
  lhs : LTLExpr,
  rhs : LTLExpr,
  trace : Array[Array[(String, Bool)]],
  index : Int,
) -> Bool? {
  match ltl_eval_from(rhs.copy(), trace, index) {
    Some(false) => return Some(false)
    Some(true) => ()
    None =>
      match ltl_eval_from(lhs.copy(), trace, index) {
        Some(true) => return None
        Some(false) => return None
        None => return None
      }
  }
  match ltl_eval_from(lhs.copy(), trace, index) {
    Some(true) => Some(true)
    Some(false) =>
      if index + 1 >= trace.length() {
        Some(true)
      } else {
        ltl_eval_release(lhs, rhs, trace, index + 1)
      }
    None =>
      if index + 1 >= trace.length() {
        None
      } else {
        match ltl_eval_release(lhs, rhs, trace, index + 1) {
          Some(false) => Some(false)
          Some(true) => None
          None => None
        }
      }
  }
}

///|
fn ltl_lookup(
  trace : Array[Array[(String, Bool)]],
  index : Int,
  name : String,
) -> Bool? {
  if index >= trace.length() {
    return None
  }
  let assignments = trace[index]
  let len = assignments.length()
  let mut i = 0
  while i < len {
    let (key, value) = assignments[i]
    if key == name {
      return Some(value)
    }
    i += 1
  }
  None
}
