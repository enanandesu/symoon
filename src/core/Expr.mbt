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
pub fn Symbol::copy(self : Symbol) -> Symbol {
  Symbol::new(self.name)
}

///|
pub enum Expr {
  Int(Int)
  Double(Double)
  Symbol(Symbol)
  Unary(UnaryOp, Expr)
  Binary(BinaryOp, Expr, Expr)
  FunctionCall(String, Array[Expr])
} derive(Eq)

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
pub fn Expr::copy(self : Expr) -> Expr {
  match self {
    Expr::Int(value) => Expr::Int(value)
    Expr::Double(value) => Expr::Double(value)
    Expr::Symbol(symbol) => Expr::Symbol(symbol.copy())
    Expr::Unary(op, inner) => Expr::Unary(op, inner.copy())
    Expr::Binary(op, left, right) => Expr::Binary(op, left.copy(), right.copy())
    Expr::FunctionCall(name, args) => {
      let copied_args = Array::new(capacity=args.length())
      for arg in args {
        copied_args.push(arg.copy())
      }
      Expr::FunctionCall(name, copied_args)
    }
  }
}

///|
pub fn SymbolicError::copy(self : SymbolicError) -> SymbolicError {
  match self {
    SymbolicError::UndefinedSymbol(name) => SymbolicError::UndefinedSymbol(name)
    SymbolicError::DomainViolation(domain, reason) =>
      SymbolicError::DomainViolation(domain, reason)
    SymbolicError::UnsupportedOperation(operation) =>
      SymbolicError::UnsupportedOperation(operation)
  }
}
