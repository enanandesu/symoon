///|
test "mod_inverse and modular square roots" {
  assert_eq(mod_inverse(3, 11), 4)
  assert_eq(mod_inverse(2, 4), 0)
  let roots = sqrt_mod(4, 7)
  assert_eq(roots, [2, 5])
  let none = sqrt_mod(3, 7)
  assert_eq(none.length(), 0)
}

///|
test "invert and crt helpers" {
  assert_eq(invert(3, 11), 4)
  assert_eq(invert(2, 4), 0)
  let (x1, m1) = crt([3, 5, 7], [2, 3, 2])
  assert_eq((x1, m1), (23, 105))
  let (x2, m2) = crt([5, 6], [-1, 1])
  assert_eq((x2, m2), (19, 30))
  let (x3, m3) = crt([3, 6], [2, 5])
  assert_eq((x3, m3), (5, 6))
  let (x4, m4) = crt([3, 5], [2, 3], symmetric=true)
  assert_eq((x4, m4), (-7, 15))
  let (mm, e, s) = crt1([99, 97, 95])
  let (x5, m5) = crt2([99, 97, 95], [49, 76, 65], mm, e, s)
  assert_eq((x5, m5), (639985, 912285))
}

///|
test "sqrt_mod_iter nthroot_mod and discrete_log" {
  assert_eq(sqrt_mod_iter(4, 7), [2, 5])
  assert_eq(sqrt_mod_iter(3, 7).length(), 0)
  let roots = nthroot_mod(2, 3, 5)
  assert_eq(roots, [3])
  let squares = nthroot_mod(1, 2, 8)
  assert_eq(squares, [1, 3, 5, 7])
  assert_eq(discrete_log(7, 3, 5), 5)
  assert_eq(discrete_log(7, 3, 1), 0)
  assert_eq(discrete_log(7, 2, 3), -1)
}

///|
test "primitive roots and checks" {
  assert_eq(primitive_root(7), 3)
  assert_eq(primitive_root(5), 2)
  assert_eq(primitive_root(2), 1)
  assert_eq(primitive_root(8), 0)
  assert_eq(is_primitive_root(3, 7), true)
  assert_eq(is_primitive_root(2, 7), false)
}

///|
test "quadratic_residues lists squares modulo n" {
  let residues = quadratic_residues(7)
  assert_eq(residues, [0, 1, 2, 4])
}

///|
test "quadratic symbols and residue checks" {
  assert_eq(legendre_symbol(2, 7), 1)
  assert_eq(jacobi_symbol(15, 23), -1)
  assert_eq(is_quad_residue(2, 7), true)
  assert_eq(is_quad_residue(3, 7), false)
}

///|
test "quadratic symbol edge cases and residue listing" {
  assert_eq(legendre_symbol(0, 7), 0)
  assert_eq(legendre_symbol(2, 8), 0)
  assert_eq(jacobi_symbol(2, 9), 1)
  assert_eq(jacobi_symbol(5, 21), 1)
  let residues = quadratic_residues(11)
  assert_eq(residues, [0, 1, 3, 4, 5, 9])
  assert_eq(is_quad_residue(3, 11), true)
  assert_eq(is_quad_residue(2, 11), false)
}

///|
test "kronecker symbol and multiplicative order" {
  assert_eq(kronecker_symbol(3, 8), -1)
  assert_eq(kronecker_symbol(5, 8), -1)
  assert_eq(kronecker_symbol(5, -7), -1)
  assert_eq(n_order(3, 7), 6)
  assert_eq(n_order(2, 9), 6)
  assert_eq(n_order(2, 10), 0)
}

///|
test "solve_congruence combines pairwise congruences" {
  let (x, modulus) = solve_congruence([(2, 3), (3, 5), (2, 7)])
  assert_eq((x, modulus), (23, 105))
  let impossible = solve_congruence([(1, 2), (0, 4)])
  assert_eq(impossible, (0, 0))
}

///|
test "solve_congruence normalizes residues and negatives" {
  let (x1, m1) = solve_congruence([(-1, 5), (1, 6)])
  assert_eq((x1, m1), (19, 30))
  let (x2, m2) = solve_congruence([(4, 5), (4, 10)])
  assert_eq((x2, m2), (4, 10))
}

///|
test "additional modular roots and logs" {
  assert_eq(sqrt_mod(10, 13), [6, 7])
  assert_eq(nthroot_mod(3, 1, 11), [3])
  assert_eq(nthroot_mod(2, 2, 8).length(), 0)
  assert_eq(discrete_log(11, 2, 9, order=10), 6)
}

///|
test "solve_congruence handles empty input" {
  assert_eq(solve_congruence([]), (0, 0))
}
