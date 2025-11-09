///|
test "coefficient_of extracts requested variable power" {
  let x = sym("x")
  let expr = int(3) * pow(x, int(2)) + int(2) * x + int(5)
  inspect(coefficient_of(expr, "x"), content="2")
  inspect(coefficient_of(expr, "x", degree=2), content="3")
  inspect(coefficient_of(expr, "x", degree=0), content="5")
  inspect(coefficient_of(expr, "y"), content="0")
}
