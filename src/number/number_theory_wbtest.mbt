///|
test "nt_gcd and nt_lcm handle common cases" {
  assert_eq(nt_gcd(54, 24), 6)
  assert_eq(nt_gcd(-54, 24), 6)
  assert_eq(nt_lcm(6, 8), 24)
  assert_eq(nt_lcm(0, 5), 0)
}

///|
test "gcd/lcm aliases match nt_ versions" {
  assert_eq(gcd(12, 18), 6)
  assert_eq(lcm(12, 18), 36)
  assert_eq(igcd(12, 18), 6)
  assert_eq(ilcm(12, 18), 36)
}

///|
test "nt_gcd_ex finds Bézout coefficients" {
  let (x, y, g) = nt_gcd_ex(12, 18)
  assert_eq((x, y, g), (-1, 1, 6))
  let (x2, y2, g2) = nt_gcd_ex(0, 5)
  assert_eq((x2, y2, g2), (0, 1, 5))
  let (x3, y3, g3) = nt_gcd_ex(-10, 15)
  assert_eq(-10 * x3 + 15 * y3, g3)
  assert_eq(g3, 5)
}

///|
test "gcdex alias matches nt_gcd_ex" {
  let (x, y, g) = gcdex(12, 18)
  assert_eq((x, y, g), (-1, 1, 6))
}

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
test "quadratic_residues lists squares modulo n" {
  let residues = quadratic_residues(7)
  assert_eq(residues, [0, 1, 2, 4])
}

///|
test "totient mobius and prime factor counters" {
  assert_eq(totient(12), 4)
  assert_eq(mobius(12), 0)
  assert_eq(mobius(11), -1)
  assert_eq(primenu(12), 2)
  assert_eq(primeomega(12), 3)
}

///|
test "mobius and prime counters cover edge cases" {
  assert_eq(mobius(-30), 1)
  assert_eq(mobius(1), 1)
  assert_eq(mobius(64), 0)
  assert_eq(primenu(1), 0)
  assert_eq(primenu(360), 3)
  assert_eq(primeomega(360), 6)
  assert_eq(primeomega(0), 0)
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
test "nt_is_prime checks small and composite numbers" {
  assert_eq(nt_is_prime(1), false)
  assert_eq(nt_is_prime(2), true)
  assert_eq(nt_is_prime(17), true)
  assert_eq(nt_is_prime(21), false)
}

///|
test "nt_is_divisible_by covers zero and negatives" {
  assert_eq(nt_is_divisible_by(10, 2), true)
  assert_eq(nt_is_divisible_by(10, 3), false)
  assert_eq(nt_is_divisible_by(0, 5), true)
  assert_eq(nt_is_divisible_by(5, 0), false)
  assert_eq(nt_is_divisible_by(-12, 3), true)
  assert_eq(nt_is_divisible_by(12, -3), true)
}

///|
test "nt_is_divisible_by_all_and_any handle collections" {
  assert_eq(nt_is_divisible_by_all(60, [2, 3, 5]), true)
  assert_eq(nt_is_divisible_by_all(12, [2, 5]), false)
  assert_eq(nt_is_divisible_by_all(10, []), true)
  assert_eq(nt_is_divisible_by_any(14, [3, 5, 7]), true)
  assert_eq(nt_is_divisible_by_any(25, [2, 4]), false)
  assert_eq(nt_is_divisible_by_any(10, []), false)
}

///|
test "nt_primes_up_to lists primes within limit" {
  let empty = nt_primes_up_to(1)
  assert_eq(empty.length(), 0)
  let primes = nt_primes_up_to(20)
  assert_eq(primes, [2, 3, 5, 7, 11, 13, 17, 19])
}

///|
test "nt_nth_prime and nt_prime_pi" {
  assert_eq(nt_nth_prime(1), 2)
  assert_eq(nt_nth_prime(10), 29)
  assert_eq(nt_nth_prime(0), 0)
  assert_eq(nt_prime(10), 29)
  assert_eq(nt_prime_pi(1), 0)
  assert_eq(nt_prime_pi(2), 1)
  assert_eq(nt_prime_pi(100), 25)
}

///|
test "nt_next_prev_prime locate neighbors" {
  assert_eq(nt_next_prime(50), 53)
  assert_eq(nt_prev_prime(50), 47)
  assert_eq(nt_next_prime(2), 3)
  assert_eq(nt_prev_prime(3), 2)
  assert_eq(nt_prev_prime(2), 0)
}

///|
test "nt_prime_range builds half-open ranges" {
  let range = nt_prime_range(10, 30)
  assert_eq(range, [11, 13, 17, 19, 23, 29])
  let small = nt_prime_range(-5, 5)
  assert_eq(small, [2, 3])
  let empty = nt_prime_range(20, 20)
  assert_eq(empty.length(), 0)
}

///|
test "nt_rand_prime picks deterministic prime inside range" {
  let default_pick = nt_rand_prime(100, 200)
  assert_eq(default_pick, 131)
  assert_eq(nt_is_prime(default_pick), true)
  assert_eq(default_pick >= 100 && default_pick < 200, true)
  let seeded = nt_rand_prime(100, 200, seed=7)
  assert_eq(seeded, 137)
  assert_eq(nt_rand_prime(14, 16), 0)
}

///|
test "nt_first_n_primes returns the requested count" {
  let none = nt_first_n_primes(0)
  assert_eq(none.length(), 0)
  let first_five = nt_first_n_primes(5)
  assert_eq(first_five, [2, 3, 5, 7, 11])
}

///|
test "nt_prime_factors factorizes integers" {
  let factors = nt_prime_factors(84)
  assert_eq(factors, [(2, 2), (3, 1), (7, 1)])
  let negative = nt_prime_factors(-45)
  assert_eq(negative, [(3, 2), (5, 1)])
  let unity = nt_prime_factors(1)
  assert_eq(unity.length(), 0)
  let zero = nt_prime_factors(0)
  assert_eq(zero.length(), 0)
}

///|
test "nt_prime_factor_list expands factors with multiplicity" {
  let list = nt_prime_factor_list(360)
  assert_eq(list, [2, 2, 2, 3, 3, 5])
  let negative = nt_prime_factor_list(-45)
  assert_eq(negative, [3, 3, 5])
  let prime_number = nt_prime_factor_list(13)
  assert_eq(prime_number, [13])
  let unity = nt_prime_factor_list(1)
  assert_eq(unity.length(), 0)
}

///|
test "nt_factorint and nt_multiplicity match expectations" {
  let f100 = nt_factorint(100)
  assert_eq(f100, [(2, 2), (5, 2)])
  let f123456 = nt_factorint(123456)
  assert_eq(f123456, [(2, 6), (3, 1), (643, 1)])
  assert_eq(nt_multiplicity(2, 100), 2)
  assert_eq(nt_multiplicity(5, 100), 2)
  assert_eq(nt_multiplicity(7, 100), 0)
  assert_eq(nt_multiplicity(2, -40), 3)
}

///|
test "factorint and multiplicity aliases mirror nt_ versions" {
  assert_eq(factorint(100), [(2, 2), (5, 2)])
  assert_eq(factorint(123456), [(2, 6), (3, 1), (643, 1)])
  assert_eq(multiplicity(2, 100), 2)
  assert_eq(multiplicity(5, 100), 2)
}

///|
test "nt_divisors count and sigma" {
  let divisors = nt_divisors(12)
  assert_eq(divisors, [1, 2, 3, 4, 6, 12])
  assert_eq(nt_divisor_count(12), 6)
  assert_eq(nt_divisors(-10), [1, 2, 5, 10])
  assert_eq(nt_divisor_count(1), 1)
  assert_eq(nt_divisor_count(0), 0)
  assert_eq(nt_divisor_sigma(12), 28)
  assert_eq(nt_divisor_sigma(12, power=2), 210)
  assert_eq(nt_divisor_sigma(1), 1)
  assert_eq(nt_divisor_sigma(0), 0)
}

///|
test "divisors, divisor_count, divisor_sigma aliases mirror nt_ versions" {
  assert_eq(divisors(12), [1, 2, 3, 4, 6, 12])
  assert_eq(divisor_count(12), 6)
  assert_eq(divisor_sigma(12), 28)
  assert_eq(divisor_sigma(12, power=2), 210)
}

///|
test "nt_totient matches known values" {
  assert_eq(nt_totient(1), 1)
  assert_eq(nt_totient(9), 6)
  assert_eq(nt_totient(36), 12)
}
