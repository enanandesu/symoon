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
