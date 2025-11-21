///|
pub fn logic_simplify(expr : LogicExpr) -> LogicExpr {
  logic_normalize(expr)
}

///|
pub fn logic_simplify_with_assignments(
  expr : LogicExpr,
  assignments : Array[(String, Bool)],
) -> LogicExpr {
  logic_apply_assignments(expr, assignments)
}
