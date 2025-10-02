///|
pub enum UnaryOp {
  Neg
  Sin
  Cos
  Tan
  Asin
  Acos
  Atan
  Sinh
  Cosh
  Tanh
  Asinh
  Acosh
  Atanh
  Exp
  Log
  Abs
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
pub fn tan(expr : Expr) -> Expr {
  Expr::Unary(UnaryOp::Tan, expr)
}

///|
pub fn asin(expr : Expr) -> Expr {
  Expr::Unary(UnaryOp::Asin, expr)
}

///|
pub fn acos(expr : Expr) -> Expr {
  Expr::Unary(UnaryOp::Acos, expr)
}

///|
pub fn atan(expr : Expr) -> Expr {
  Expr::Unary(UnaryOp::Atan, expr)
}

///|
pub fn sinh(expr : Expr) -> Expr {
  Expr::Unary(UnaryOp::Sinh, expr)
}

///|
pub fn cosh(expr : Expr) -> Expr {
  Expr::Unary(UnaryOp::Cosh, expr)
}

///|
pub fn tanh(expr : Expr) -> Expr {
  Expr::Unary(UnaryOp::Tanh, expr)
}

///|
pub fn asinh(expr : Expr) -> Expr {
  Expr::Unary(UnaryOp::Asinh, expr)
}

///|
pub fn acosh(expr : Expr) -> Expr {
  Expr::Unary(UnaryOp::Acosh, expr)
}

///|
pub fn atanh(expr : Expr) -> Expr {
  Expr::Unary(UnaryOp::Atanh, expr)
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
pub fn abs(expr : Expr) -> Expr {
  Expr::Unary(UnaryOp::Abs, expr)
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
pub impl Add for Expr with add(self, other) {
  add(self, other)
}

///|
pub impl Sub for Expr with sub(self, other) {
  sub(self, other)
}

///|
pub impl Mul for Expr with mul(self, other) {
  mul(self, other)
}

///|
pub impl Div for Expr with div(self, other) {
  div(self, other)
}

///|
pub impl Neg for Expr with neg(self) {
  neg(self)
}
