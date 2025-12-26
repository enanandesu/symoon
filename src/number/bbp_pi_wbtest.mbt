///|
test "pi_hex_digits matches leading digits" {
  assert_eq(pi_hex_digits(0, prec=3), "324")
  assert_eq(pi_hex_digits(1, prec=4), "243f")
}

///|
test "pi_hex_digits edge cases" {
  assert_eq(pi_hex_digits(0, prec=0), "")
  assert_eq(pi_hex_digits(-1, prec=3), "")
  assert_eq(pi_hex_digits(1, prec=0), "")
}
