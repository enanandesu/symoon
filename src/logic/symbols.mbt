///|
pub const LOGIC_TRUE_SYMBOL : String = "True"

///|
pub const LOGIC_FALSE_SYMBOL : String = "False"

///|
pub const LOGIC_NOT_SYMBOL : String = "Not"

///|
pub const LOGIC_AND_SYMBOL : String = "And"

///|
pub const LOGIC_OR_SYMBOL : String = "Or"

///|
pub const LOGIC_XOR_SYMBOL : String = "Xor"

///|
pub const LOGIC_ITE_SYMBOL : String = "Ite"

///|
pub const LOGIC_IMPLIES_SYMBOL : String = "Implies"

///|
pub const LOGIC_EQUIVALENT_SYMBOL : String = "Equivalent"

///|
pub fn logic_true() -> LogicExpr {
  LogicExpr::Bool(true)
}

///|
pub fn logic_false() -> LogicExpr {
  LogicExpr::Bool(false)
}

///|
pub fn logic_symbol(name : String) -> LogicExpr {
  LogicExpr::Symbol(name)
}
