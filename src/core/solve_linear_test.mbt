///|
fn assert_expr_close(expr : Expr, expected : Double) -> Unit {
  match expr {
    Expr::Int(value) => {
      let diff = (value.to_double() - expected).abs()
      if diff >= 1.0e-9 {
        abort("expected close numeric value")
      }
    }
    Expr::Double(value) => {
      let diff = (value - expected).abs()
      if diff >= 1.0e-9 {
        abort("expected close numeric value")
      }
    }
    _ => abort("expected numeric literal")
  }
}

///|
test "solve_linear_equation solves single variable" {
  let x = sym("x")
  let lhs = add(mul(int(2), x), int(4))
  let rhs = int(0)
  inspect(solve_linear_equation(lhs, rhs, "x"), content="-2")
}

///|
test "solve_linear_equation solves single variable 2" {
  let x = sym("x")
  let lhs = mul(int(0), x)
  let rhs = int(0)
  inspect(
    solve_linear_equation(lhs, rhs, "x"),
    content="solve_linear(x, 0 * x, 0)",
  )
}

///|
test "solve_linear_equation detects no solution when inconsistent" {
  let lhs = int(3)
  let rhs = int(0)
  inspect(solve_linear_equation(lhs, rhs, "x"), content="no_solution()")
}

///|
test "solve_linear_equation falls back for quadratic" {
  let x = sym("x")
  let lhs = add(add(pow(x, int(2)), mul(int(2), x)), int(2))
  let rhs = int(0)
  inspect(
    solve_linear_equation(lhs, rhs, "x"),
    content="solve_linear(x, x ^ 2 + 2 * x + 2, 0)",
  )
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

///|
test "solve_linear_system_n solves three variables" {
  let x = sym("x")
  let y = sym("y")
  let z = sym("z")
  let equations = Array::new()
  equations.push((add(add(x, y), z), int(6)))
  equations.push((add(add(mul(int(2), x), mul(int(3), y)), z), int(11)))
  equations.push((add(sub(x, y), mul(int(2), z)), int(5)))
  let variables = Array::new()
  variables.push("x")
  variables.push("y")
  variables.push("z")
  let solutions = solve_linear_system_n(equations, variables)
  assert_eq(solutions.length(), 3)
  inspect(solutions[0], content="1")
  inspect(solutions[1], content="2")
  inspect(solutions[2], content="3")
}

///|
test "solve_linear_system_n solves four variables" {
  let x = sym("x")
  let y = sym("y")
  let z = sym("z")
  let w = sym("w")
  let equations = Array::new()
  equations.push((w, int(3)))
  equations.push((add(z, w), int(7)))
  equations.push((add(add(y, z), w), int(9)))
  equations.push((add(add(add(x, y), z), w), int(10)))
  let variables = Array::new()
  variables.push("x")
  variables.push("y")
  variables.push("z")
  variables.push("w")
  let solutions = solve_linear_system_n(equations, variables)
  assert_eq(solutions.length(), 4)
  inspect(solutions[0], content="1")
  inspect(solutions[1], content="2")
  inspect(solutions[2], content="4")
  inspect(solutions[3], content="3")
}

///|
test "solve_linear_system_n handles fractional solutions" {
  let x = sym("x")
  let y = sym("y")
  let z = sym("z")
  let equations = Array::new()
  equations.push((add(add(mul(int(2), x), mul(int(3), y)), z), int(1)))
  equations.push((add(sub(x, y), mul(int(2), z)), int(4)))
  equations.push((add(add(mul(int(3), x), y), mul(int(4), z)), int(7)))
  let variables = Array::new()
  variables.push("x")
  variables.push("y")
  variables.push("z")
  let solutions = solve_linear_system_n(equations, variables)
  assert_expr_close(solutions[0], 0.5)
  assert_expr_close(solutions[1], -0.5)
  assert_expr_close(solutions[2], 1.5)
}

///|
test "solve_linear_system_n detects no solution" {
  let x = sym("x")
  let y = sym("y")
  let equations = Array::new()
  equations.push((add(x, y), int(1)))
  equations.push((add(x, y), int(2)))
  let variables = Array::new()
  variables.push("x")
  variables.push("y")
  let solutions = solve_linear_system_n(equations, variables)
  assert_eq(solutions.length(), 2)
  inspect(solutions[0], content="no_solution()")
  inspect(solutions[1], content="no_solution()")
}
