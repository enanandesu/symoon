///|
pub fn evaluate(
  expr : Expr,
  lookup : (String) -> Double?, //TODO:再包装
) -> Result[Double, SymbolicError] {
  match expr {
    Constant(literal) => evaluate_constant(literal)
    Symbol(symbol) => {
      let key = symbol.name
      let query_key = key
      match lookup(query_key) {
        Some(value) => Ok(value)
        None => Err(UndefinedSymbol(key))
      }
    }
    Unary(Neg, inner) =>
      match evaluate(inner, lookup) {
        Ok(value) => Ok(-value)
        Err(err) => Err(err)
      }
    Unary(_, _) => Err(UnsupportedOperation("unary evaluation".to_string()))
    Binary(op, left, right) =>
      match (evaluate(left, lookup), evaluate(right, lookup)) {
        (Ok(lhs), Ok(rhs)) =>
          match op {
            Add => Ok(lhs + rhs)
            Sub => Ok(lhs - rhs)
            Mul => Ok(lhs * rhs)
            Div =>
              if rhs == 0.0 {
                Err(
                  DomainViolation(
                    "division".to_string(),
                    "division by zero".to_string(),
                  ),
                )
              } else {
                Ok(lhs / rhs)
              }
            Pow => Ok(@math.pow(lhs, rhs))
          }
        (Err(err), _) => Err(err)
        (_, Err(err)) => Err(err)
      }
    FunctionCall(name, _) => Err(UnsupportedOperation("function call: " + name))
  }
}

///|
fn evaluate_constant(
  literal : ConstantLiteral,
) -> Result[Double, SymbolicError] {
  match literal {
    ConstantLiteral::Integer(value) => Ok(value.to_double())
    ConstantLiteral::Float(value) => Ok(value)
    ConstantLiteral::PosInfinity =>
      Err(UnsupportedOperation("positive infinity literal".to_string()))
    ConstantLiteral::NegInfinity =>
      Err(UnsupportedOperation("negative infinity literal".to_string()))
    ConstantLiteral::NaN => Err(UnsupportedOperation("nan literal".to_string()))
  }
}
