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
pub enum ConstantLiteral {
  Integer(Int)
  Float(Double)
  PosInfinity
  NegInfinity
  NaN
} derive(Eq, Show)

///|
pub enum Expr {
  Constant(ConstantLiteral)
  Symbol(Symbol)
  Unary(UnaryOp, Expr)
  Binary(BinaryOp, Expr, Expr)
  FunctionCall(String, Array[Expr])
} derive(Eq)

///|
pub fn int(value : Int) -> Expr {
  Constant(ConstantLiteral::Integer(value))
}

///|
pub fn double(value : Double) -> Expr {
  Constant(ConstantLiteral::Float(value))
}

///|
pub fn pos_infinity() -> Expr {
  Constant(ConstantLiteral::PosInfinity)
}

///|
pub fn neg_infinity() -> Expr {
  Constant(ConstantLiteral::NegInfinity)
}

///|
pub fn nan() -> Expr {
  Constant(ConstantLiteral::NaN)
}

///|
pub fn sym(name : String) -> Expr {
  Symbol(Symbol::new(name))
}

///|
pub fn Expr::copy(self : Expr) -> Expr {
  match self {
    Constant(literal) => Constant(literal)
    Symbol(symbol) => Symbol(symbol.copy())
    Unary(op, inner) => Unary(op, inner.copy())
    Binary(op, left, right) => Binary(op, left.copy(), right.copy())
    FunctionCall(name, args) => {
      let copied_args = Array::new(capacity=args.length())
      for arg in args {
        copied_args.push(arg.copy())
      }
      FunctionCall(name, copied_args)
    }
  }
}

///|
pub fn SymbolicError::copy(self : SymbolicError) -> SymbolicError {
  match self {
    UndefinedSymbol(name) => UndefinedSymbol(name)
    DomainViolation(domain, reason) => DomainViolation(domain, reason)
    UnsupportedOperation(operation) => UnsupportedOperation(operation)
  }
}
