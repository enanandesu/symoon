///|
pub struct PatternBindings {
  entries : Array[(String, Expr)]
}

///|
pub fn PatternBindings::new() -> PatternBindings {
  { entries: Array::new() }
}

///|
pub fn PatternBindings::is_empty(self : PatternBindings) -> Bool {
  self.entries.length() == 0
}

///|
pub fn PatternBindings::len(self : PatternBindings) -> Int {
  self.entries.length()
}

///|
pub fn PatternBindings::copy(self : PatternBindings) -> PatternBindings {
  let duplicated = Array::new(capacity=self.entries.length())
  for entry in self.entries {
    let (name, value) = entry
    duplicated.push((name, value.copy()))
  }
  { entries: duplicated }
}

///|
pub fn PatternBindings::bind_expr(
  bindings : PatternBindings,
  name : String,
  expr : Expr,
) -> PatternBindings? {
  let len = bindings.entries.length()
  let updated = Array::new(capacity=len + 1)
  let mut found = false
  for entry in bindings.entries {
    let (existing_name, existing_expr) = entry
    if existing_name == name {
      if existing_expr == expr {
        updated.push((existing_name, existing_expr))
        found = true
      } else {
        return None
      }
    } else {
      updated.push((existing_name, existing_expr))
    }
  }
  if !found {
    updated.push((name, expr.copy()))
  }
  Some({ entries: updated })
}

///|
pub fn PatternBindings::get(self : PatternBindings, name : String) -> Expr? {
  for entry in self.entries {
    let (entry_name, entry_expr) = entry
    if entry_name == name {
      return Some(entry_expr.copy())
    }
  }
  None
}

///|
pub fn PatternBindings::contains(self : PatternBindings, name : String) -> Bool {
  for entry in self.entries {
    let (entry_name, _) = entry
    if entry_name == name {
      return true
    }
  }
  false
}

///|
pub fn PatternBindings::to_array(
  self : PatternBindings,
) -> Array[(String, Expr)] {
  let result = Array::new(capacity=self.entries.length())
  for entry in self.entries {
    let (name, value) = entry
    result.push((name, value.copy()))
  }
  result
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
  FunctionCall(String?, Array[Pattern])
  OneOf(Array[Pattern])
  All(Array[Pattern])
  Guard(Pattern, (Expr, PatternBindings) -> Bool)
}

///|
pub fn Pattern::copy(self : Pattern) -> Pattern {
  match self {
    Pattern::Any => Pattern::Any
    Pattern::Wildcard(name) => Pattern::Wildcard(name)
    Pattern::GuardedWildcard(name, predicate) =>
      Pattern::GuardedWildcard(name, predicate)
    Pattern::Exact(expr) => Pattern::Exact(expr.copy())
    Pattern::Symbol(maybe_name) => Pattern::Symbol(maybe_name)
    Pattern::IntLiteral(maybe_value) => Pattern::IntLiteral(maybe_value)
    Pattern::DoubleLiteral(maybe_value) => Pattern::DoubleLiteral(maybe_value)
    Pattern::Unary(maybe_op, inner) => Pattern::Unary(maybe_op, inner.copy())
    Pattern::Binary(maybe_op, left, right) =>
      Pattern::Binary(maybe_op, left.copy(), right.copy())
    Pattern::FunctionCall(maybe_name, patterns) => {
      let copied = patterns.map((item : Pattern) => item.copy())
      Pattern::FunctionCall(maybe_name, copied)
    }
    Pattern::OneOf(options) => {
      let copied = options.map((item : Pattern) => item.copy())
      Pattern::OneOf(copied)
    }
    Pattern::All(requirements) => {
      let copied = requirements.map((item : Pattern) => item.copy())
      Pattern::All(copied)
    }
    Pattern::Guard(inner, predicate) => Pattern::Guard(inner.copy(), predicate)
  }
}

///|
pub fn pattern_any() -> Pattern {
  Pattern::Any
}

///|
pub fn pattern_wildcard(name : String) -> Pattern {
  Pattern::Wildcard(name)
}

///|
pub fn pattern_guarded(name : String, predicate : (Expr) -> Bool) -> Pattern {
  Pattern::GuardedWildcard(name, predicate)
}

///|
pub fn pattern_exact(expr : Expr) -> Pattern {
  Pattern::Exact(expr)
}

///|
pub fn pattern_symbol(name? : String? = None) -> Pattern {
  Pattern::Symbol(name)
}

///|
pub fn pattern_int(value? : Int? = None) -> Pattern {
  Pattern::IntLiteral(value)
}

///|
pub fn pattern_double(value? : Double? = None) -> Pattern {
  Pattern::DoubleLiteral(value)
}

///|
pub fn pattern_unary(inner : Pattern, op? : UnaryOp? = None) -> Pattern {
  Pattern::Unary(op, inner)
}

///|
pub fn pattern_binary(
  left : Pattern,
  right : Pattern,
  op? : BinaryOp? = None,
) -> Pattern {
  Pattern::Binary(op, left, right)
}

///|
pub fn pattern_call(name? : String? = None, args : Array[Pattern]) -> Pattern {
  Pattern::FunctionCall(name, args)
}

///|
pub fn pattern_one_of(patterns : Array[Pattern]) -> Pattern {
  Pattern::OneOf(patterns)
}

///|
pub fn pattern_all_of(patterns : Array[Pattern]) -> Pattern {
  Pattern::All(patterns)
}

///|
pub fn pattern_guard(
  pattern : Pattern,
  predicate : (Expr, PatternBindings) -> Bool,
) -> Pattern {
  Pattern::Guard(pattern, predicate)
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
    Pattern::Any => Some(bindings)
    Pattern::Wildcard(name) => PatternBindings::bind_expr(bindings, name, expr)
    Pattern::GuardedWildcard(name, predicate_fn) =>
      if predicate_fn(expr.copy()) {
        PatternBindings::bind_expr(bindings, name, expr)
      } else {
        None
      }
    Pattern::Exact(template) =>
      if template == expr {
        Some(bindings)
      } else {
        None
      }
    Pattern::Symbol(maybe_name) =>
      match expr {
        Expr::Symbol(symbol) =>
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
    Pattern::IntLiteral(maybe_value) =>
      match expr {
        Expr::Int(value) =>
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
    Pattern::Unary(maybe_op, inner_pattern) =>
      match expr {
        Expr::Unary(op, inner) =>
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
    Pattern::Binary(maybe_op, left_pattern, right_pattern) =>
      match expr {
        Expr::Binary(op, left, right) =>
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
        _ => None
      }
    Pattern::FunctionCall(maybe_name, arg_patterns) =>
      match expr {
        Expr::FunctionCall(name, args) => {
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
        }
        _ => None
      }
    Pattern::OneOf(options) => {
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
    Pattern::All(requirements) => {
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
    Pattern::Guard(inner, predicate) =>
      match match_internal(inner, expr.copy(), bindings) {
        Some(updated) =>
          if predicate(expr.copy(), updated.copy()) {
            Some(updated)
          } else {
            None
          }
        None => None
      }
  }
}

///|
pub fn match_expr(pattern : Pattern, expr : Expr) -> PatternBindings? {
  match_internal(pattern, expr, PatternBindings::new())
}

///|
pub fn matches(pattern : Pattern, expr : Expr) -> Bool {
  match match_expr(pattern, expr) {
    Some(_) => true
    None => false
  }
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
    Expr::Unary(op, inner) =>
      match rewrite_once(inner, rules) {
        Some(new_inner) => Some(Expr::Unary(op, new_inner))
        None => None
      }
    Expr::Binary(op, left, right) =>
      match rewrite_once(left, rules) {
        Some(new_left) => Some(Expr::Binary(op, new_left, right))
        None =>
          match rewrite_once(right, rules) {
            Some(new_right) => Some(Expr::Binary(op, left, new_right))
            None => None
          }
      }
    Expr::FunctionCall(name, args) => {
      let len_args = args.length()
      for i in 0..<len_args {
        let arg_expr = args[i]
        let maybe_new = rewrite_once(arg_expr, rules)
        match maybe_new {
          Some(new_arg) => {
            let new_args = args.map((item : Expr) => item.copy())
            new_args[i] = new_arg
            return Some(Expr::FunctionCall(name, new_args))
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
    iterations = iterations + 1
  }
  current
}
