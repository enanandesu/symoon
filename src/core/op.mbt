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

//TODO:重载运算符

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
