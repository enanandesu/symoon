///|
fn binary_precedence(op : BinaryOp) -> Int {
  match op {
    BinaryOp::Add => 1
    BinaryOp::Sub => 1
    BinaryOp::Mul => 2
    BinaryOp::Div => 2
    BinaryOp::Pow => 3
  }
}

///|
fn needs_parentheses(
  expr : Expr,
  parent_op : BinaryOp,
  is_right : Bool,
) -> Bool {
  match expr {
    Expr::Binary(child_op, _, _) => {
      let child_prec = binary_precedence(child_op)
      let parent_prec = binary_precedence(parent_op)
      if child_prec < parent_prec {
        true
      } else if child_prec > parent_prec {
        false
      } else {
        match parent_op {
          BinaryOp::Add => child_op == BinaryOp::Sub && is_right
          BinaryOp::Sub => true
          BinaryOp::Mul =>
            match child_op {
              BinaryOp::Add => true
              BinaryOp::Sub => true
              BinaryOp::Div => is_right
              _ => false
            }
          BinaryOp::Div => true
          BinaryOp::Pow => true
        }
      }
    }
    Expr::Unary(UnaryOp::Neg, _) =>
      match parent_op {
        BinaryOp::Pow => true
        _ => false
      }
    _ => false
  }
}

///|
fn format_expr(expr : Expr, wrap : Bool) -> String {
  match expr {
    Expr::Int(value) => value.to_string()
    Expr::Double(value) => value.to_string()
    Expr::Symbol(symbol) => symbol.name
    Expr::Unary(UnaryOp::Neg, inner) => {
      let base = match inner {
        Expr::Int(value) => "-" + value.to_string()
        Expr::Double(value) => "-" + value.to_string()
        Expr::Symbol(symbol) => "-" + symbol.name
        other => "-(" + format_expr(other, false) + ")"
      }
      if wrap {
        "(" + base + ")"
      } else {
        base
      }
    }
    Expr::Unary(op, inner) => {
      let func = match op {
        UnaryOp::Sin => "sin"
        UnaryOp::Cos => "cos"
        UnaryOp::Tan => "tan"
        UnaryOp::Asin => "asin"
        UnaryOp::Acos => "acos"
        UnaryOp::Atan => "atan"
        UnaryOp::Sinh => "sinh"
        UnaryOp::Cosh => "cosh"
        UnaryOp::Tanh => "tanh"
        UnaryOp::Asinh => "asinh"
        UnaryOp::Acosh => "acosh"
        UnaryOp::Atanh => "atanh"
        UnaryOp::Exp => "exp"
        UnaryOp::Log => "log"
        UnaryOp::Abs => "abs"
        UnaryOp::Neg => abort("unexpected neg unary formatting")
      }
      let argument = format_expr(inner, false)
      let base = func + "(" + argument + ")"
      if wrap {
        "(" + base + ")"
      } else {
        base
      }
    }
    Expr::Binary(op, left, right) => {
      let op_symbol = match op {
        BinaryOp::Add => " + "
        BinaryOp::Sub => " - "
        BinaryOp::Mul => " * "
        BinaryOp::Div => " / "
        BinaryOp::Pow => " ^ "
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
    Expr::FunctionCall(name, args) => {
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
fn format_expr_latex(expr : Expr, wrap : Bool) -> String {
  match expr {
    Expr::Int(value) => value.to_string()
    Expr::Double(value) => value.to_string()
    Expr::Symbol(symbol) => symbol.name
    Expr::Unary(UnaryOp::Neg, inner) => {
      let base = match inner {
        Expr::Int(value) => "-" + value.to_string()
        Expr::Double(value) => "-" + value.to_string()
        Expr::Symbol(symbol) => "-" + symbol.name
        other => "-\\left(" + format_expr_latex(other, false) + "\\right)"
      }
      latex_wrap(base, wrap)
    }
    Expr::Unary(UnaryOp::Abs, inner) => {
      let inner_str = format_expr_latex(inner, false)
      let base = "\\left|" + inner_str + "\\right|"
      latex_wrap(base, wrap)
    }
    Expr::Unary(op, inner) => {
      let func = match op {
        UnaryOp::Sin => "\\sin"
        UnaryOp::Cos => "\\cos"
        UnaryOp::Tan => "\\tan"
        UnaryOp::Asin => "\\arcsin"
        UnaryOp::Acos => "\\arccos"
        UnaryOp::Atan => "\\arctan"
        UnaryOp::Sinh => "\\sinh"
        UnaryOp::Cosh => "\\cosh"
        UnaryOp::Tanh => "\\tanh"
        UnaryOp::Asinh => "\\operatorname{asinh}"
        UnaryOp::Acosh => "\\operatorname{acosh}"
        UnaryOp::Atanh => "\\operatorname{atanh}"
        UnaryOp::Exp => "\\exp"
        UnaryOp::Log => "\\log"
        UnaryOp::Neg => abort("unexpected neg unary latex formatting")
        UnaryOp::Abs => abort("unexpected abs unary latex formatting")
      }
      let argument = format_expr_latex(inner, false)
      let base = func + "\\left(" + argument + "\\right)"
      latex_wrap(base, wrap)
    }
    Expr::Binary(BinaryOp::Div, left, right) => {
      let numerator = format_expr_latex(left, false)
      let denominator = format_expr_latex(right, false)
      let base = "\\frac{" + numerator + "}{" + denominator + "}"
      latex_wrap(base, wrap)
    }
    Expr::Binary(BinaryOp::Pow, left, right) => {
      let left_str = format_expr_latex(
        left,
        needs_parentheses(left, BinaryOp::Pow, false),
      )
      let right_str = format_expr_latex(right, false)
      let base = left_str + "^{" + right_str + "}"
      latex_wrap(base, wrap)
    }
    Expr::Binary(op, left, right) => {
      let op_symbol = match op {
        BinaryOp::Add => " + "
        BinaryOp::Sub => " - "
        BinaryOp::Mul => " \\cdot "
        BinaryOp::Div => abort("div handled earlier")
        BinaryOp::Pow => abort("pow handled earlier")
      }
      let left_str = format_expr_latex(left, needs_parentheses(left, op, false))
      let right_str = format_expr_latex(
        right,
        needs_parentheses(right, op, true),
      )
      let base = left_str + op_symbol + right_str
      latex_wrap(base, wrap)
    }
    Expr::FunctionCall(name, args) => {
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
  }
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
