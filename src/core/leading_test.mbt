///|
test "leading_coefficient handles polynomials and fallbacks" {
  let x = sym("x")
  let quadratic = int(3) * pow(x, int(2)) + int(2) * x + int(5)
  inspect(leading_coefficient(quadratic, "x"), content="3")
  let cubic = double(0.5) * pow(x, int(3)) - pow(x, int(2)) + x
  inspect(leading_coefficient(cubic, "x"), content="0.5")
  inspect(leading_coefficient(int(4), "x"), content="4")
  inspect(leading_coefficient(sin(x), "x"), content="leading_coeff(x, sin(x))")
}
