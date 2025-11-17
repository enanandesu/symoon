///|
pub struct PatternBindings {
  entries : Map[String, Expr]
}

///|
pub fn PatternBindings::new() -> PatternBindings {
  { entries: {} }
}

///|
pub fn PatternBindings::is_empty(self : PatternBindings) -> Bool {
  self.entries.is_empty()
}

///|
pub fn PatternBindings::len(self : PatternBindings) -> Int {
  self.entries.length()
}

///|
pub fn PatternBindings::copy(self : PatternBindings) -> PatternBindings {
  let updated = {}
  for entry in self.entries {
    let (name, expr) = entry
    updated.set(name, expr.copy())
  }
  { entries: updated }
}

///|
pub fn PatternBindings::bind_expr(
  bindings : PatternBindings,
  name : String,
  expr : Expr,
) -> PatternBindings? {
  let updated = {}
  let mut found = false
  for entry in bindings.entries {
    let (existing_name, existing_expr) = entry
    if existing_name == name {
      if existing_expr == expr {
        updated.set(existing_name, existing_expr)
        found = true
      } else {
        return None
      }
    } else {
      updated.set(existing_name, existing_expr)
    }
  }
  if !found {
    updated.set(name, expr.copy())
  }
  Some({ entries: updated })
}

///|
pub fn PatternBindings::get(self : PatternBindings, name : String) -> Expr? {
  self.entries.get(name)
}

///|
pub fn PatternBindings::expect(self : PatternBindings, name : String) -> Expr {
  match self.entries.get(name) {
    Some(expr) => expr
    None => abort("missing binding: " + name)
  }
}

///|
pub fn PatternBindings::contains(self : PatternBindings, name : String) -> Bool {
  self.entries.contains(name)
}

///|
pub fn PatternBindings::to_array(
  self : PatternBindings,
) -> Array[(String, Expr)] {
  self.entries.to_array()
}

///|
pub enum Pattern {
  Any
  Wildcard(String)
  GuardedWildcard(String, (Expr) -> Bool)
  Exact(Expr)
  Symbol(String?)
  IntLiteral(Int?)
  DoubleLiteral(Double?)
  Unary(UnaryOp?, Pattern)
  Binary(BinaryOp?, Pattern, Pattern)
  Commutative(BinaryOp, Array[Pattern])
  FunctionCall(String?, Array[Pattern])
  OneOf(Array[Pattern])
  All(Array[Pattern])
  Guard(Pattern, (Expr, PatternBindings) -> Bool)
}

///|
pub fn Pattern::copy(self : Pattern) -> Pattern {
  match self {
    Any => Any
    Wildcard(name) => Wildcard(name)
    GuardedWildcard(name, predicate) => GuardedWildcard(name, predicate)
    Exact(expr) => Exact(expr.copy())
    Symbol(maybe_name) => Symbol(maybe_name)
    IntLiteral(maybe_value) => IntLiteral(maybe_value)
    DoubleLiteral(maybe_value) => DoubleLiteral(maybe_value)
    Unary(maybe_op, inner) => Unary(maybe_op, inner.copy())
    Binary(maybe_op, left, right) => Binary(maybe_op, left.copy(), right.copy())
    Commutative(op, patterns) => {
      let copied = patterns.map(item => item.copy())
      Commutative(op, copied)
    }
    FunctionCall(maybe_name, patterns) => {
      let copied = patterns.map(item => item.copy())
      FunctionCall(maybe_name, copied)
    }
    OneOf(options) => {
      let copied = options.map(item => item.copy())
      OneOf(copied)
    }
    All(requirements) => {
      let copied = requirements.map(item => item.copy())
      All(copied)
    }
    Guard(inner, predicate) => Guard(inner.copy(), predicate)
  }
}

///|
pub fn pattern_any() -> Pattern {
  Any
}

///|
pub fn pattern_wildcard(name : String) -> Pattern {
  Wildcard(name)
}

///|
pub fn pattern_guarded(name : String, predicate : (Expr) -> Bool) -> Pattern {
  GuardedWildcard(name, predicate)
}

///|
pub fn pattern_exact(expr : Expr) -> Pattern {
  Exact(expr)
}

///|
pub fn pattern_symbol(name? : String? = None) -> Pattern {
  Symbol(name)
}

///|
pub fn pattern_int(value? : Int? = None) -> Pattern {
  IntLiteral(value)
}

///|
pub fn pattern_double(value? : Double? = None) -> Pattern {
  DoubleLiteral(value)
}

///|
pub fn pattern_unary(inner : Pattern, op? : UnaryOp? = None) -> Pattern {
  Unary(op, inner)
}

///|
pub fn pattern_binary(
  left : Pattern,
  right : Pattern,
  op? : BinaryOp? = None,
) -> Pattern {
  Binary(op, left, right)
}

///|
fn pattern_commutative(op : BinaryOp, operands : Array[Pattern]) -> Pattern {
  Commutative(op, operands)
}

///|
pub fn pattern_sum(operands : Array[Pattern]) -> Pattern {
  pattern_commutative(Add, operands)
}

///|
pub fn pattern_product(operands : Array[Pattern]) -> Pattern {
  pattern_commutative(Mul, operands)
}

///|
pub fn pattern_call(name? : String? = None, args : Array[Pattern]) -> Pattern {
  FunctionCall(name, args)
}

///|
pub fn pattern_one_of(patterns : Array[Pattern]) -> Pattern {
  OneOf(patterns)
}

///|
pub fn pattern_all_of(patterns : Array[Pattern]) -> Pattern {
  All(patterns)
}

///|
pub fn pattern_guard(
  pattern : Pattern,
  predicate : (Expr, PatternBindings) -> Bool,
) -> Pattern {
  Guard(pattern, predicate)
}

///|
pub struct RewriteRule {
  pattern : Pattern
  builder : (PatternBindings) -> Expr
  condition : ((PatternBindings) -> Bool)?
}

///|
pub fn RewriteRule::new(
  pattern : Pattern,
  builder : (PatternBindings) -> Expr,
) -> RewriteRule {
  { pattern, builder, condition: None }
}

///|
pub fn RewriteRule::with_condition(
  rule : RewriteRule,
  condition : (PatternBindings) -> Bool,
) -> RewriteRule {
  { pattern: rule.pattern, builder: rule.builder, condition: Some(condition) }
}

///|
fn match_internal(
  pattern : Pattern,
  expr : Expr,
  bindings : PatternBindings,
) -> PatternBindings? {
  match pattern {
    Any => Some(bindings)
    Wildcard(name) => PatternBindings::bind_expr(bindings, name, expr)
    GuardedWildcard(name, predicate_fn) =>
      if predicate_fn(expr.copy()) {
        PatternBindings::bind_expr(bindings, name, expr)
      } else {
        None
      }
    Exact(template) => if template == expr { Some(bindings) } else { None }
    Symbol(maybe_name) =>
      match expr {
        Symbol(symbol) =>
          match maybe_name {
            Some(expected) =>
              if symbol.name == expected {
                Some(bindings)
              } else {
                None
              }
            None => Some(bindings)
          }
        _ => None
      }
    IntLiteral(maybe_value) =>
      match expr {
        Int(value) =>
          match maybe_value {
            Some(expected) =>
              if value == expected {
                Some(bindings)
              } else {
                None
              }
            None => Some(bindings)
          }
        _ => None
      }
    Pattern::DoubleLiteral(maybe_value) =>
      match expr {
        Expr::Double(value) =>
          match maybe_value {
            Some(expected) =>
              if value == expected {
                Some(bindings)
              } else {
                None
              }
            None => Some(bindings)
          }
        _ => None
      }
    Unary(maybe_op, inner_pattern) =>
      match expr {
        Unary(op, inner) =>
          match maybe_op {
            Some(expected) =>
              if expected == op {
                match_internal(inner_pattern, inner, bindings)
              } else {
                None
              }
            None => match_internal(inner_pattern, inner, bindings)
          }
        _ => None
      }
    Binary(maybe_op, left_pattern, right_pattern) =>
      if expr is Binary(op, left, right) {
        match maybe_op {
          Some(expected) =>
            if expected == op {
              match_internal(
                right_pattern,
                right,
                match match_internal(left_pattern, left, bindings) {
                  Some(updated) => updated
                  None => return None
                },
              )
            } else {
              None
            }
          None =>
            match match_internal(left_pattern, left, bindings) {
              Some(updated) => match_internal(right_pattern, right, updated)
              None => None
            }
        }
      } else {
        None
      }
    Commutative(op, requirements) => {
      if !is_commutative_expr(expr.copy(), op) {
        return None
      }
      let mut terms = []
      terms = flatten_commutative_terms(expr, op, terms)
      if terms.length() != requirements.length() {
        return None
      }
      let usage = create_usage_flags(terms.length())
      match match_commutative_terms(requirements, 0, terms, usage, bindings) {
        Some(result) => Some(result)
        None => None
      }
    }
    FunctionCall(maybe_name, arg_patterns) =>
      if expr is FunctionCall(name, args) {
        let _ = match maybe_name {
          Some(expected) => if expected != name { return None }
          None => ()
        }
        if args.length() != arg_patterns.length() {
          return None
        }
        let mut current = bindings
        let len = arg_patterns.length()
        for i in 0..<len {
          let pattern_item = arg_patterns[i]
          let arg_expr = args[i]
          match match_internal(pattern_item, arg_expr, current) {
            Some(updated) => current = updated
            None => return None
          }
        }
        Some(current)
      } else {
        None
      }
    OneOf(options) => {
      let len = options.length()
      for i in 0..<len {
        let option = options[i]
        match match_internal(option.copy(), expr.copy(), bindings.copy()) {
          Some(result) => return Some(result)
          None => continue
        }
      }
      None
    }
    All(requirements) => {
      let len = requirements.length()
      let mut current = bindings
      for i in 0..<len {
        let requirement = requirements[i]
        match match_internal(requirement.copy(), expr.copy(), current) {
          Some(updated) => current = updated
          None => return None
        }
      }
      Some(current)
    }
    Guard(inner, predicate) =>
      if match_internal(inner, expr.copy(), bindings) is Some(updated) &&
        predicate(expr.copy(), updated.copy()) {
        Some(updated)
      } else {
        None
      }
  }
}

///|
pub fn match_expr(pattern : Pattern, expr : Expr) -> PatternBindings? {
  match_internal(pattern, expr, PatternBindings::new())
}

///|
fn is_commutative_expr(expr : Expr, op : BinaryOp) -> Bool {
  match expr {
    Binary(node_op, _, _) => node_op == op
    _ => false
  }
}

///|
fn flatten_commutative_terms(
  expr : Expr,
  op : BinaryOp,
  terms : Array[Expr],
) -> Array[Expr] {
  match expr {
    Binary(node_op, left, right) if node_op == op => {
      let collected = flatten_commutative_terms(left, op, terms)
      flatten_commutative_terms(right, op, collected)
    }
    other => {
      let updated = terms
      updated.push(other)
      updated
    }
  }
}

///|
fn create_usage_flags(len : Int) -> Array[Bool] {
  Array::make(len, false)
}

///|
fn match_commutative_terms(
  patterns : Array[Pattern],
  pattern_index : Int,
  terms : Array[Expr],
  used : Array[Bool],
  bindings : PatternBindings,
) -> PatternBindings? {
  if pattern_index >= patterns.length() {
    return Some(bindings)
  }
  let current_pattern = patterns[pattern_index]
  let len_terms = terms.length()
  for i in 0..<len_terms {
    if used[i] {
      continue
    }
    let term_expr = terms[i]
    match
      match_internal(current_pattern.copy(), term_expr.copy(), bindings.copy()) {
      Some(updated) => {
        used[i] = true
        match
          match_commutative_terms(
            patterns,
            pattern_index + 1,
            terms,
            used,
            updated,
          ) {
          Some(result) => return Some(result)
          None => used[i] = false
        }
      }
      None => continue
    }
  }
  None
}

///|
pub fn matches(pattern : Pattern, expr : Expr) -> Bool {
  match_expr(pattern, expr) is Some(_)
}

///|
pub fn try_apply_rule(rule : RewriteRule, expr : Expr) -> Expr? {
  let pattern = rule.pattern
  let builder_fn = rule.builder
  let condition_fn = rule.condition
  match match_expr(pattern, expr.copy()) {
    Some(bindings) => {
      match condition_fn {
        Some(predicate) => if !predicate(bindings.copy()) { return None }
        None => ()
      }
      Some(builder_fn(bindings))
    }
    None => None
  }
}

///|
pub fn rewrite_once(expr : Expr, rules : Array[RewriteRule]) -> Expr? {
  for rule in rules {
    match try_apply_rule(rule, expr.copy()) {
      Some(candidate) => return Some(candidate)
      None => continue
    }
  }
  match expr {
    Unary(op, inner) =>
      match rewrite_once(inner, rules) {
        Some(new_inner) => Some(Unary(op, new_inner))
        None => None
      }
    Binary(op, left, right) =>
      match rewrite_once(left, rules) {
        Some(new_left) => Some(Binary(op, new_left, right))
        None =>
          match rewrite_once(right, rules) {
            Some(new_right) => Some(Binary(op, left, new_right))
            None => None
          }
      }
    FunctionCall(name, args) => {
      let len_args = args.length()
      for i in 0..<len_args {
        let arg_expr = args[i]
        let maybe_new = rewrite_once(arg_expr, rules)
        match maybe_new {
          Some(new_arg) => {
            let new_args = args.map(item => item.copy())
            new_args[i] = new_arg
            return Some(FunctionCall(name, new_args))
          }
          None => continue
        }
      }
      None
    }
    _ => None
  }
}

///|
pub fn rewrite(
  expr : Expr,
  rules : Array[RewriteRule],
  max_iterations? : Int = 12,
) -> Expr {
  let mut current = expr
  let mut iterations = 0
  while iterations < max_iterations {
    match rewrite_once(current.copy(), rules) {
      Some(next) => {
        if next == current {
          return current
        }
        current = next
      }
      None => return current
    }
    iterations += 1
  }
  current
}
