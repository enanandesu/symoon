///|
pub fn logic_to_latex(expr : LogicExpr) -> String {
  format_logic_expr(logic_normalize(expr), -1)
}

///|
fn format_logic_expr(expr : LogicExpr, parent_precedence : Int) -> String {
  match expr {
    Bool(value) =>
      wrap_if_needed(
        if value { "\\top" } else { "\\bot" },
        6,
        parent_precedence,
      )
    Symbol(name) => wrap_if_needed(format_logic_symbol(name), 6, parent_precedence)
    Not(inner) => {
      let precedence = 5
      let inner_str = format_logic_expr(inner, precedence)
      let builder = StringBuilder::new()
      builder.write_string("\\neg ")
      builder.write_string(inner_str)
      wrap_if_needed(builder.to_string(), precedence, parent_precedence)
    }
    And(terms) =>
      format_variadic_terms(terms, "\\land", "\\top", 4, parent_precedence)
    Or(terms) => format_variadic_terms(terms, "\\lor", "\\bot", 3, parent_precedence)
    Xor(terms) =>
      format_variadic_terms(terms, "\\oplus", "\\bot", 2, parent_precedence)
    Ite(condition, then_branch, else_branch) => {
      let builder = StringBuilder::new()
      builder.write_string("\\operatorname{ITE}\\left(")
      builder.write_string(format_logic_expr(condition, -1))
      builder.write_string(", ")
      builder.write_string(format_logic_expr(then_branch, -1))
      builder.write_string(", ")
      builder.write_string(format_logic_expr(else_branch, -1))
      builder.write_string("\\right)")
      wrap_if_needed(builder.to_string(), 6, parent_precedence)
    }
    Implies(lhs, rhs) => format_binary_expr(lhs, rhs, "\\rightarrow", 1, parent_precedence)
    Equivalent(lhs, rhs) =>
      format_binary_expr(lhs, rhs, "\\leftrightarrow", 0, parent_precedence)
  }
}

///|
fn format_variadic_terms(
  terms : Array[LogicExpr],
  symbol : String,
  fallback : String,
  precedence : Int,
  parent_precedence : Int,
) -> String {
  let len = terms.length()
  if len == 0 {
    return wrap_if_needed(fallback, precedence, parent_precedence)
  }
  let builder = StringBuilder::new()
  for i in 0..<len {
    if i > 0 {
      builder.write_char(' ')
      builder.write_string(symbol)
      builder.write_char(' ')
    }
    builder.write_string(format_logic_expr(terms[i], precedence))
  }
  wrap_if_needed(builder.to_string(), precedence, parent_precedence)
}

///|
fn format_binary_expr(
  lhs : LogicExpr,
  rhs : LogicExpr,
  symbol : String,
  precedence : Int,
  parent_precedence : Int,
) -> String {
  let builder = StringBuilder::new()
  builder.write_string(format_logic_expr(lhs, precedence))
  builder.write_char(' ')
  builder.write_string(symbol)
  builder.write_char(' ')
  builder.write_string(format_logic_expr(rhs, precedence - 1))
  wrap_if_needed(builder.to_string(), precedence, parent_precedence)
}

///|
fn format_logic_symbol(name : String) -> String {
  name
}

///|
fn wrap_if_needed(content : String, precedence : Int, parent_precedence : Int) -> String {
  if parent_precedence >= 0 && precedence < parent_precedence {
    let builder = StringBuilder::new()
    builder.write_string("\\left(")
    builder.write_string(content)
    builder.write_string("\\right)")
    builder.to_string()
  } else {
    content
  }
}
