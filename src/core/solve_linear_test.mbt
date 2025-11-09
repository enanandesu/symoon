///|
test "solve_linear_equation solves single variable" {
  let x = sym("x")
  let lhs = add(mul(int(2), x), int(4))
  let rhs = int(0)
  inspect(solve_linear_equation(lhs, rhs, "x"), content="-2")
}

///|
test "solve_linear_system solves two variables" {
  let x = sym("x")
  let y = sym("y")
  let lhs1 = add(mul(int(2), x), y)
  let rhs1 = int(3)
  let lhs2 = sub(x, y)
  let rhs2 = int(1)
  let (sol_x, sol_y) = solve_linear_system(lhs1, rhs1, lhs2, rhs2, "x", "y")
  inspect(sol_x, content="4 / 3")
  inspect(sol_y, content="1 / 3")
}
