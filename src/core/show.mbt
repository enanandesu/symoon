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
        UnaryOp::Exp => "exp"
        UnaryOp::Log => "ln"
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
pub impl Show for Expr with to_string(self) {
  format_expr(self, false)
}

///|
pub impl Show for Expr with output(self, logger) {
  logger.write_string(self.to_string())
}
