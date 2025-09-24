///|
pub fn evaluate(
  expr : Expr,
  lookup : (String) -> Double?,//TODO:再包装
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
