///|
pub enum SymbolicError {
  UndefinedSymbol(String)
  DomainViolation(String, String)
  UnsupportedOperation(String)
} derive(Show, Eq)

///|
pub struct Symbol {
  name : String
} derive(Eq, Show, Hash)

///|
pub fn Symbol::new(name : String) -> Symbol {
  { name, }
}

///|
pub enum UnaryOp {
  Neg
  Sin
  Cos
  Exp
  Log
} derive(Eq, Show, Hash)

///|
pub enum BinaryOp {
  Add
  Sub
  Mul
  Div
  Pow
} derive(Eq, Show, Hash)

///|
pub enum Expr {
  Int(Int)
  Double(Double)
  Symbol(Symbol)
  Unary(UnaryOp, Expr)
  Binary(BinaryOp, Expr, Expr)
  FunctionCall(String, Array[Expr])
} derive(Eq, Show)

///|
pub fn int(value : Int) -> Expr {
  Expr::Int(value)
}

///|
pub fn double(value : Double) -> Expr {
  Expr::Double(value)
}

///|
pub fn sym(name : String) -> Expr {
  Expr::Symbol(Symbol::new(name))
}

///|
pub fn neg(expr : Expr) -> Expr {
  Expr::Unary(UnaryOp::Neg, expr)
}

///|
pub fn sin(expr : Expr) -> Expr {
  Expr::Unary(UnaryOp::Sin, expr)
}

///|
pub fn cos(expr : Expr) -> Expr {
  Expr::Unary(UnaryOp::Cos, expr)
}

///|
pub fn exp(expr : Expr) -> Expr {
  Expr::Unary(UnaryOp::Exp, expr)
}

///|
pub fn log(expr : Expr) -> Expr {
  Expr::Unary(UnaryOp::Log, expr)
}

///|
pub fn add(lhs : Expr, rhs : Expr) -> Expr {
  Expr::Binary(BinaryOp::Add, lhs, rhs)
}

///|
pub fn sub(lhs : Expr, rhs : Expr) -> Expr {
  Expr::Binary(BinaryOp::Sub, lhs, rhs)
}

///|
pub fn mul(lhs : Expr, rhs : Expr) -> Expr {
  Expr::Binary(BinaryOp::Mul, lhs, rhs)
}

///|
pub fn div(lhs : Expr, rhs : Expr) -> Expr {
  Expr::Binary(BinaryOp::Div, lhs, rhs)
}

///|
pub fn pow(base : Expr, exponent : Expr) -> Expr {
  Expr::Binary(BinaryOp::Pow, base, exponent)
}

///|
fn is_zero_literal(expr : Expr) -> (Bool, Expr) {
  match expr {
    Expr::Int(value) =>
      if value == 0 {
        (true, Expr::Int(0))
      } else {
        (false, Expr::Int(value))
      }
    Expr::Double(value) =>
      if value == 0.0 {
        (true, Expr::Double(0.0))
      } else {
        (false, Expr::Double(value))
      }
    other => (false, other)
  }
}

///|
fn is_one_literal(expr : Expr) -> (Bool, Expr) {
  match expr {
    Expr::Int(value) =>
      if value == 1 {
        (true, Expr::Int(1))
      } else {
        (false, Expr::Int(value))
      }
    Expr::Double(value) =>
      if value == 1.0 {
        (true, Expr::Double(1.0))
      } else {
        (false, Expr::Double(value))
      }
    other => (false, other)
  }
}

///|
pub fn simplify(expr : Expr) -> Expr {
  match expr {
    Expr::Unary(UnaryOp::Neg, inner) => {
      let simplified = simplify(inner)
      match simplified {
        Expr::Int(value) => Expr::Int(-value)
        Expr::Double(value) => Expr::Double(-value)
        other => Expr::Unary(UnaryOp::Neg, other)
      }
    }
    Expr::Unary(op, inner) => Expr::Unary(op, simplify(inner))
    Expr::Binary(BinaryOp::Add, left, right) => {
      let (left_zero, left_clean) = is_zero_literal(simplify(left))
      let (right_zero, right_clean) = is_zero_literal(simplify(right))
      if left_zero {
        right_clean
      } else if right_zero {
        left_clean
      } else {
        match (left_clean, right_clean) {
          (Expr::Int(lhs), Expr::Int(rhs)) => Expr::Int(lhs + rhs)
          (Expr::Double(lhs), Expr::Double(rhs)) => Expr::Double(lhs + rhs)
          (lhs, rhs) => Expr::Binary(BinaryOp::Add, lhs, rhs)
        }
      }
    }
    Expr::Binary(BinaryOp::Sub, left, right) => {
      let left_s = simplify(left)
      let (right_zero, right_clean) = is_zero_literal(simplify(right))
      if right_zero {
        left_s
      } else {
        match (left_s, right_clean) {
          (Expr::Int(lhs), Expr::Int(rhs)) => Expr::Int(lhs - rhs)
          (Expr::Double(lhs), Expr::Double(rhs)) => Expr::Double(lhs - rhs)
          (lhs, rhs) => Expr::Binary(BinaryOp::Sub, lhs, rhs)
        }
      }
    }
    Expr::Binary(BinaryOp::Mul, left, right) => {
      let (left_zero, left_clean) = is_zero_literal(simplify(left))
      let (right_zero, right_clean) = is_zero_literal(simplify(right))
      if left_zero || right_zero {
        Expr::Int(0)
      } else {
        let (left_one, left_value) = is_one_literal(left_clean)
        if left_one {
          right_clean
        } else {
          let (right_one, right_value) = is_one_literal(right_clean)
          if right_one {
            left_value
          } else {
            match (left_value, right_value) {
              (Expr::Int(lhs), Expr::Int(rhs)) => Expr::Int(lhs * rhs)
              (Expr::Double(lhs), Expr::Double(rhs)) => Expr::Double(lhs * rhs)
              (lhs, rhs) => Expr::Binary(BinaryOp::Mul, lhs, rhs)
            }
          }
        }
      }
    }
    Expr::Binary(BinaryOp::Div, left, right) => {
      let left_s = simplify(left)
      let (right_one, right_clean) = is_one_literal(simplify(right))
      if right_one {
        left_s
      } else {
        match (left_s, right_clean) {
          (Expr::Int(lhs), Expr::Int(rhs)) =>
            if rhs != 0 && lhs % rhs == 0 {
              Expr::Int(lhs / rhs)
            } else {
              Expr::Binary(BinaryOp::Div, Expr::Int(lhs), Expr::Int(rhs))
            }
          (Expr::Double(lhs), Expr::Double(rhs)) => Expr::Double(lhs / rhs)
          (lhs, rhs) => Expr::Binary(BinaryOp::Div, lhs, rhs)
        }
      }
    }
    Expr::Binary(BinaryOp::Pow, base, exponent) => {
      let base_s = simplify(base)
      let (exp_zero, exp_clean) = is_zero_literal(simplify(exponent))
      if exp_zero {
        Expr::Int(1)
      } else {
        let (exp_one, exp_value) = is_one_literal(exp_clean)
        if exp_one {
          base_s
        } else {
          Expr::Binary(BinaryOp::Pow, base_s, exp_value)
        }
      }
    }
    Expr::FunctionCall(name, args) => {
      let simplified_args = args.map(arg => simplify(arg))
      Expr::FunctionCall(name, simplified_args)
    }
    other => other
  }
}

///|
fn diff_fallback(variable_name : String, expr : Expr, tag : String) -> Expr {
  let args = [sym(variable_name), expr]
  Expr::FunctionCall(tag, args)
}

///|
pub fn differentiate(expr : Expr, variable_name : String) -> Expr {
  match expr {
    Expr::Int(_) => Expr::Int(0)
    Expr::Double(_) => Expr::Int(0)
    Expr::Symbol(symbol) =>
      if symbol.name == variable_name {
        Expr::Int(1)
      } else {
        Expr::Int(0)
      }
    Expr::Unary(UnaryOp::Neg, inner) => {
      let var_for_inner = variable_name
      Expr::Unary(UnaryOp::Neg, differentiate(inner, var_for_inner))
    }
    Expr::Unary(_, inner) =>
      diff_fallback(variable_name, inner, "diff_unary".to_string())
    Expr::Binary(BinaryOp::Add, left, right) => {
      let var_left = variable_name
      let var_right = variable_name
      let left_diff = differentiate(left, var_left)
      let right_diff = differentiate(right, var_right)
      Expr::Binary(BinaryOp::Add, left_diff, right_diff)
    }
    Expr::Binary(BinaryOp::Sub, left, right) => {
      let var_left = variable_name
      let var_right = variable_name
      let left_diff = differentiate(left, var_left)
      let right_diff = differentiate(right, var_right)
      Expr::Binary(BinaryOp::Sub, left_diff, right_diff)
    }
    Expr::Binary(BinaryOp::Mul, left, right) => {
      let var_left = variable_name
      let var_right = variable_name
      let left_diff = differentiate(left, var_left)
      let right_diff = differentiate(right, var_right)
      let term_left = Expr::Binary(BinaryOp::Mul, left, right_diff)
      let term_right = Expr::Binary(BinaryOp::Mul, left_diff, right)
      Expr::Binary(BinaryOp::Add, term_left, term_right)
    }
    Expr::Binary(BinaryOp::Div, left, right) =>
      diff_fallback(
        variable_name,
        Expr::Binary(BinaryOp::Div, left, right),
        "diff_div".to_string(),
      )
    Expr::Binary(BinaryOp::Pow, base, exponent) =>
      diff_fallback(
        variable_name,
        Expr::Binary(BinaryOp::Pow, base, exponent),
        "diff_pow".to_string(),
      )
    Expr::FunctionCall(name, args) => {
      let call_expr = Expr::FunctionCall(name, args)
      diff_fallback(variable_name, call_expr, "diff_call".to_string())
    }
  }
}

///|
pub fn evaluate(
  expr : Expr,
  lookup : (String) -> Double?,
) -> Result[Double, SymbolicError] {
  match expr {
    Expr::Int(value) => Ok(value.to_double())
    Expr::Double(value) => Ok(value)
    Expr::Symbol(symbol) => {
      let key = symbol.name
      let query_key = key
      match lookup(query_key) {
        Some(value) => Ok(value)
        None => Err(SymbolicError::UndefinedSymbol(key))
      }
    }
    Expr::Unary(UnaryOp::Neg, inner) =>
      match evaluate(inner, lookup) {
        Ok(value) => Ok(-value)
        Err(err) => Err(err)
      }
    Expr::Unary(_, _) =>
      Err(SymbolicError::UnsupportedOperation("unary evaluation".to_string()))
    Expr::Binary(op, left, right) =>
      match (evaluate(left, lookup), evaluate(right, lookup)) {
        (Ok(lhs), Ok(rhs)) =>
          match op {
            BinaryOp::Add => Ok(lhs + rhs)
            BinaryOp::Sub => Ok(lhs - rhs)
            BinaryOp::Mul => Ok(lhs * rhs)
            BinaryOp::Div =>
              if rhs == 0.0 {
                Err(
                  SymbolicError::DomainViolation(
                    "division".to_string(),
                    "division by zero".to_string(),
                  ),
                )
              } else {
                Ok(lhs / rhs)
              }
            BinaryOp::Pow => Ok(@math.pow(lhs, rhs))
          }
        (Err(err), _) => Err(err)
        (_, Err(err)) => Err(err)
      }
    Expr::FunctionCall(name, _) =>
      Err(SymbolicError::UnsupportedOperation("function call: " + name))
  }
}
