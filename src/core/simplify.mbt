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
          //TODO:处理Int和Double混合的情况
          //TODO:合并同类项
          //TODO:处理多项式的展开与合并
          //TODO:处理乘方的展开与合并
          //TODO:处理函数的展开与合并
          //TODO:处理一些数学恒等式
          //TODO:分数相加通分
          //TODO:分式约分 因式分解
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
