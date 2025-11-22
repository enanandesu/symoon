///|
test "nt_gcd and nt_lcm handle common cases" {
  assert_eq(nt_gcd(54, 24), 6)
  assert_eq(nt_gcd(-54, 24), 6)
  assert_eq(nt_lcm(6, 8), 24)
  assert_eq(nt_lcm(0, 5), 0)
}

///|
test "nt_is_prime checks small and composite numbers" {
  assert_eq(nt_is_prime(1), false)
  assert_eq(nt_is_prime(2), true)
  assert_eq(nt_is_prime(17), true)
  assert_eq(nt_is_prime(21), false)
}

///|
test "nt_primes_up_to lists primes within limit" {
  let empty = nt_primes_up_to(1)
  assert_eq(empty.length(), 0)
  let primes = nt_primes_up_to(20)
  assert_eq(primes, [2, 3, 5, 7, 11, 13, 17, 19])
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
}

///|
test "nt_totient matches known values" {
  assert_eq(nt_totient(1), 1)
  assert_eq(nt_totient(9), 6)
  assert_eq(nt_totient(36), 12)
}
