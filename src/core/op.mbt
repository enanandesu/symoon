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
pub fn UnaryOp::copy(self : UnaryOp) -> UnaryOp {
  match self {
    Neg => Neg
    Sin => Sin
    Cos => Cos
    Tan => Tan
    Asin => Asin
    Acos => Acos
    Atan => Atan
    Sinh => Sinh
    Cosh => Cosh
    Tanh => Tanh
    Asinh => Asinh
    Acosh => Acosh
    Atanh => Atanh
    Exp => Exp
    Log => Log
    Abs => Abs
  }
}

///|
pub fn BinaryOp::copy(self : BinaryOp) -> BinaryOp {
  match self {
    Add => BinaryOp::Add
    Sub => BinaryOp::Sub
    Mul => BinaryOp::Mul
    Div => BinaryOp::Div
    Pow => BinaryOp::Pow
  }
}

///|
pub fn neg(expr : Expr) -> Expr {
  Unary(Neg, expr)
}

///|
pub fn sin(expr : Expr) -> Expr {
  Unary(Sin, expr)
}

///|
pub fn cos(expr : Expr) -> Expr {
  Unary(Cos, expr)
}

///|
pub fn tan(expr : Expr) -> Expr {
  Unary(Tan, expr)
}

///|
pub fn asin(expr : Expr) -> Expr {
  Unary(Asin, expr)
}

///|
pub fn acos(expr : Expr) -> Expr {
  Unary(Acos, expr)
}

///|
pub fn atan(expr : Expr) -> Expr {
  Unary(Atan, expr)
}

///|
pub fn sinh(expr : Expr) -> Expr {
  Unary(Sinh, expr)
}

///|
pub fn cosh(expr : Expr) -> Expr {
  Unary(Cosh, expr)
}

///|
pub fn tanh(expr : Expr) -> Expr {
  Unary(Tanh, expr)
}

///|
pub fn asinh(expr : Expr) -> Expr {
  Unary(Asinh, expr)
}

///|
pub fn acosh(expr : Expr) -> Expr {
  Unary(Acosh, expr)
}

///|
pub fn atanh(expr : Expr) -> Expr {
  Unary(Atanh, expr)
}

///|
pub fn exp(expr : Expr) -> Expr {
  Unary(Exp, expr)
}

///|
pub fn log(expr : Expr) -> Expr {
  Unary(Log, expr)
}

///|
pub fn abs(expr : Expr) -> Expr {
  Unary(Abs, expr)
}

///|
pub fn add(lhs : Expr, rhs : Expr) -> Expr {
  Binary(Add, lhs, rhs)
}

///|
pub fn sub(lhs : Expr, rhs : Expr) -> Expr {
  Binary(Sub, lhs, rhs)
}

///|
pub fn mul(lhs : Expr, rhs : Expr) -> Expr {
  Binary(Mul, lhs, rhs)
}

///|
pub fn div(lhs : Expr, rhs : Expr) -> Expr {
  Binary(Div, lhs, rhs)
}

///|
pub fn pow(base : Expr, exponent : Expr) -> Expr {
  Binary(Pow, base, exponent)
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
