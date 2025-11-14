///|
pub fn logic_not(expr : LogicExpr) -> LogicExpr {
  logic_not_canonical(logic_normalize(expr))
}

///|
pub fn logic_and(operands : Array[LogicExpr]) -> LogicExpr {
  logic_and_internal(normalize_operands(operands))
}

///|
pub fn logic_or(operands : Array[LogicExpr]) -> LogicExpr {
  logic_or_internal(normalize_operands(operands))
}

///|
pub fn logic_xor(operands : Array[LogicExpr]) -> LogicExpr {
  logic_xor_internal(normalize_operands(operands))
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
    Implies(lhs, rhs) =>
      logic_implies_internal(logic_normalize(lhs), logic_normalize(rhs))
    Equivalent(lhs, rhs) =>
      logic_equivalent_internal(logic_normalize(lhs), logic_normalize(rhs))
  }
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
fn logic_signature(expr : LogicExpr) -> String {
  match expr {
    Bool(value) => if value { LOGIC_TRUE_SYMBOL } else { LOGIC_FALSE_SYMBOL }
    Symbol(name) => "sym:" + name
    Not(inner) => unary_signature(LOGIC_NOT_SYMBOL, inner)
    And(terms) => signature_for_list(LOGIC_AND_SYMBOL, terms)
    Or(terms) => signature_for_list(LOGIC_OR_SYMBOL, terms)
    Xor(terms) => signature_for_list(LOGIC_XOR_SYMBOL, terms)
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
