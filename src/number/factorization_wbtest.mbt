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
test "sum_of_squares detects representability" {
  assert_eq(sum_of_squares(5), 1)
  assert_eq(sum_of_squares(3), 0)
  assert_eq(sum_of_squares(0), 1)
  assert_eq(sum_of_squares(-1), 0)
}

///|
test "factor helpers primefactors and perfect_power" {
  assert_eq(primefactors(84), [2, 3, 7])
  assert_eq(primefactors(-45), [3, 5])
  assert_eq(perfect_power(27), true)
  assert_eq(perfect_power(16), true)
  assert_eq(perfect_power(18), false)
  assert_eq(perfect_power(-8), true)
  assert_eq(perfect_power(-27), true)
  assert_eq(perfect_power(-16), false)
  assert_eq(trailing(40), 3)
  assert_eq(trailing(-40), 3)
  let factors = pollard_rho(84)
  assert_eq(factors, [(2, 2), (3, 1), (7, 1)])
  let factors2 = pollard_pm1(45)
  assert_eq(factors2, [(3, 2), (5, 1)])
}

///|
test "ecm and qs factorization wrappers" {
  assert_eq(ecm(84), [(2, 2), (3, 1), (7, 1)])
  assert_eq(qs(45), [(3, 2), (5, 1)])
  assert_eq(ecm(1).length(), 0)
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
  assert_eq(f100.get(2), Some(2))
  assert_eq(f100.get(5), Some(2))
  assert_eq(f100.get(7), None)
  let mut entries = 0
  for _ in f100 {
    entries += 1
  }
  assert_eq(entries, 2)
  let f123456 = nt_factorint(123456)
  assert_eq(f123456.get(2), Some(6))
  assert_eq(f123456.get(3), Some(1))
  assert_eq(f123456.get(643), Some(1))
  let mut entries2 = 0
  for _ in f123456 {
    entries2 += 1
  }
  assert_eq(entries2, 3)
  assert_eq(nt_multiplicity(2, 100), 2)
  assert_eq(nt_multiplicity(5, 100), 2)
  assert_eq(nt_multiplicity(7, 100), 0)
  assert_eq(nt_multiplicity(2, -40), 3)
}

///|
test "factorint and multiplicity aliases mirror nt_ versions" {
  let f100 = factorint(100)
  assert_eq(f100.get(2), Some(2))
  assert_eq(f100.get(5), Some(2))
  let f123456 = factorint(123456)
  assert_eq(f123456.get(2), Some(6))
  assert_eq(f123456.get(3), Some(1))
  assert_eq(f123456.get(643), Some(1))
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

///|
test "carmichael function computes lambda" {
  assert_eq(carmichael(1), 1)
  assert_eq(carmichael(2), 1)
  assert_eq(carmichael(4), 2)
  assert_eq(carmichael(8), 2)
  assert_eq(carmichael(9), 6)
  assert_eq(carmichael(15), 4)
  assert_eq(carmichael(21), 6)
  assert_eq(carmichael(0), 0)
}

///|
test "prime divisors and sigma powers" {
  assert_eq(nt_divisors(13), [1, 13])
  assert_eq(nt_divisor_count(13), 2)
  assert_eq(nt_divisor_sigma(13), 14)
  assert_eq(nt_divisor_sigma(13, power=0), 2)
  assert_eq(nt_multiplicity(1, 10), 0)
  assert_eq(totient(13), 12)
}
