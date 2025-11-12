///|
fn binary_precedence(op : BinaryOp) -> Int {
  match op {
    Add => 1
    Sub => 1
    Mul => 2
    Div => 2
    Pow => 3
  }
}

///|
fn needs_parentheses(
  expr : Expr,
  parent_op : BinaryOp,
  is_right : Bool,
) -> Bool {
  match expr {
    Binary(child_op, _, _) => {
      let child_prec = binary_precedence(child_op)
      let parent_prec = binary_precedence(parent_op)
      if child_prec < parent_prec {
        true
      } else if child_prec > parent_prec {
        false
      } else {
        match parent_op {
          Add => child_op == Sub && is_right
          Div | Sub | Pow => true
          Mul =>
            match child_op {
              Add | Sub => true
              Div => is_right
              _ => false
            }
        }
      }
    }
    Unary(Neg, _) =>
      match parent_op {
        Pow => true
        _ => false
      }
    _ => false
  }
}

///|
fn format_expr(expr : Expr, wrap : Bool) -> String {
  match expr {
    Int(value) => value.to_string()
    Double(value) => value.to_string()
    Symbol(symbol) => symbol.name
    Unary(Neg, inner) => {
      let base = match inner {
        Int(value) => "-" + value.to_string()
        Double(value) => "-" + value.to_string()
        Symbol(symbol) => "-" + symbol.name
        other => "-(" + format_expr(other, false) + ")"
      }
      if wrap {
        "(" + base + ")"
      } else {
        base
      }
    }
    Unary(op, inner) => {
      let func = match op {
        Sin => "sin"
        Cos => "cos"
        Tan => "tan"
        Asin => "asin"
        Acos => "acos"
        Atan => "atan"
        Sinh => "sinh"
        Cosh => "cosh"
        Tanh => "tanh"
        Asinh => "asinh"
        Acosh => "acosh"
        Atanh => "atanh"
        Exp => "exp"
        Log => "log"
        Abs => "abs"
        Neg => abort("unexpected neg unary formatting")
      }
      let argument = format_expr(inner, false)
      let base = func + "(" + argument + ")"
      if wrap {
        "(" + base + ")"
      } else {
        base
      }
    }
    Binary(op, left, right) => {
      let op_symbol = match op {
        Add => " + "
        Sub => " - "
        Mul => " * "
        Div => " / "
        Pow => " ^ "
      }
      let left_str = format_expr(left, needs_parentheses(left, op, false))
      let right_str = format_expr(right, needs_parentheses(right, op, true))
      let base = left_str + op_symbol + right_str
      if wrap {
        "(" + base + ")"
      } else {
        base
      }
    }
    FunctionCall(name, args) => {
      let builder = StringBuilder::new()
      builder.write_string(name)
      builder.write_char('(')
      let mut first = true
      for arg in args {
        if first {
          first = false
        } else {
          builder.write_string(", ")
        }
        builder.write_string(format_expr(arg, false))
      }
      builder.write_char(')')
      let base = builder.to_string()
      if wrap {
        "(" + base + ")"
      } else {
        base
      }
    }
  }
}

///|
fn latex_wrap(content : String, wrap : Bool) -> String {
  if wrap {
    "\\left(" + content + "\\right)"
  } else {
    content
  }
}

///|
fn format_symbol_latex(symbol : Symbol) -> String {
  let name = symbol.name
  if name == "pi" || name == "Pi" {
    return "\\pi"
  }
  if name == "tau" || name == "Tau" {
    return "\\tau"
  }
  if name == "E" {
    return "e"
  }
  if name == "EulerGamma" {
    return "\\gamma"
  }
  if name == "Catalan" {
    return "G"
  }
  if name == "GoldenRatio" {
    return "\\varphi"
  }
  if name == "GoldenRatioConjugate" {
    return "\\varphi^{*}"
  }
  if name == "SilverRatio" {
    return "\\delta_{S}"
  }
  if name == "Sqrt2" {
    return "\\sqrt{2}"
  }
  if name == "Sqrt3" {
    return "\\sqrt{3}"
  }
  if name == "Sqrt5" {
    return "\\sqrt{5}"
  }
  if name == "Log2" {
    return "\\log 2"
  }
  if name == "Log10E" {
    return "\\log_{10} e"
  }
  if name == "I" || name == "ImaginaryUnit" {
    return "i"
  }
  name
}

///|
fn format_expr_latex(expr : Expr, wrap : Bool) -> String {
  match expr {
    Int(value) => value.to_string()
    Double(value) => value.to_string()
    Symbol(symbol) => format_symbol_latex(symbol)
    Unary(Neg, inner) => {
      let base = match inner {
        Int(value) => "-" + value.to_string()
        Double(value) => "-" + value.to_string()
        Symbol(symbol) => "-" + symbol.name
        other => "-\\left(" + format_expr_latex(other, false) + "\\right)"
      }
      latex_wrap(base, wrap)
    }
    Unary(Abs, inner) => {
      let inner_str = format_expr_latex(inner, false)
      let base = "\\left|" + inner_str + "\\right|"
      latex_wrap(base, wrap)
    }
    Unary(op, inner) => {
      let func = match op {
        Sin => "\\sin"
        Cos => "\\cos"
        Tan => "\\tan"
        Asin => "\\arcsin"
        Acos => "\\arccos"
        Atan => "\\arctan"
        Sinh => "\\sinh"
        Cosh => "\\cosh"
        Tanh => "\\tanh"
        Asinh => "\\operatorname{asinh}"
        Acosh => "\\operatorname{acosh}"
        Atanh => "\\operatorname{atanh}"
        Exp => "\\exp"
        Log => "\\log"
        Neg => abort("unexpected neg unary latex formatting")
        Abs => abort("unexpected abs unary latex formatting")
      }
      let argument = format_expr_latex(inner, false)
      let base = func + "\\left(" + argument + "\\right)"
      latex_wrap(base, wrap)
    }
    Binary(Div, left, right) => {
      let numerator = format_expr_latex(left, false)
      let denominator = format_expr_latex(right, false)
      let base = "\\frac{" + numerator + "}{" + denominator + "}"
      latex_wrap(base, wrap)
    }
    Binary(Pow, left, right) => {
      let left_str = format_expr_latex(
        left,
        needs_parentheses(left, Pow, false),
      )
      let right_str = format_expr_latex(right, false)
      let base = left_str + "^{" + right_str + "}"
      latex_wrap(base, wrap)
    }
    Binary(op, left, right) => {
      let op_symbol = match op {
        Add => " + "
        Sub => " - "
        Mul => " \\cdot "
        Div => abort("div handled earlier")
        Pow => abort("pow handled earlier")
      }
      let left_str = format_expr_latex(left, needs_parentheses(left, op, false))
      let right_str = format_expr_latex(
        right,
        needs_parentheses(right, op, true),
      )
      let base = left_str + op_symbol + right_str
      latex_wrap(base, wrap)
    }
    FunctionCall(name, args) => format_function_call_latex(name, args, wrap)
  }
}

///|
fn format_function_call_latex(
  name : String,
  args : Array[Expr],
  wrap : Bool,
) -> String {
  if name == "diff_call" && args.length() == 2 {
    format_diff_call_latex(args, wrap)
  } else {
    format_regular_function_call_latex(name, args, wrap)
  }
}

///|
fn format_regular_function_call_latex(
  name : String,
  args : Array[Expr],
  wrap : Bool,
) -> String {
  let builder = StringBuilder::new()
  builder.write_string("\\operatorname{")
  builder.write_string(name)
  builder.write_string("}\\left(")
  let mut first = true
  for arg in args {
    if first {
      first = false
    } else {
      builder.write_string(", ")
    }
    builder.write_string(format_expr_latex(arg, false))
  }
  builder.write_string("\\right)")
  let base = builder.to_string()
  latex_wrap(base, wrap)
}

///|
fn format_diff_call_latex(args : Array[Expr], wrap : Bool) -> String {
  let variable_expr = args[0]
  let target_expr = args[1]
  let variable = format_expr_latex(variable_expr, false)
  let target = format_expr_latex(target_expr, false)
  let numerator = "d"
  let denominator = "d " + variable
  let derivative = "\\frac{" +
    numerator +
    "}{" +
    denominator +
    "}\\left(" +
    target +
    "\\right)"
  latex_wrap(derivative, wrap)
}

///|
pub fn to_latex(expr : Expr) -> String {
  format_expr_latex(expr, false)
}

///|
pub impl Show for Expr with to_string(self) {
  format_expr(self, false)
}

///|
pub impl Show for Expr with output(self, logger) {
  logger.write_string(self.to_string())
}
