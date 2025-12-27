///|
test "totient mobius and prime factor counters" {
  assert_eq(totient(12), 4)
  assert_eq(mobius(12), 0)
  assert_eq(mobius(11), -1)
  assert_eq(mobius(30), -1)
  assert_eq(mobius(210), 1)
  assert_eq(primenu(12), 2)
  assert_eq(primeomega(12), 3)
  assert_eq(primenu(360360), 6)
  assert_eq(primeomega(360360), 9)
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
  assert_eq(sum_of_squares(21), 0)
  assert_eq(sum_of_squares(45), 1)
  assert_eq(sum_of_squares(0), 1)
  assert_eq(sum_of_squares(-1), 0)
}

///|
test "factor helpers primefactors and perfect_power" {
  assert_eq(primefactors(84), [2, 3, 7])
  assert_eq(primefactors(-45), [3, 5])
  assert_eq(primefactors(1), [])
  assert_eq(perfect_power(0), true)
  assert_eq(perfect_power(1), true)
  assert_eq(perfect_power(-1), true)
  assert_eq(perfect_power(27), true)
  assert_eq(perfect_power(16), true)
  assert_eq(perfect_power(18), false)
  assert_eq(perfect_power(-8), true)
  assert_eq(perfect_power(-27), true)
  assert_eq(perfect_power(-16), false)
  assert_eq(trailing(40), 3)
  assert_eq(trailing(-40), 3)
  assert_eq(trailing(0), 0)
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
test "ecm and qs handle primes and larger composites" {
  assert_eq(ecm(13), [(13, 1)])
  assert_eq(ecm(-45), [(3, 2), (5, 1)])
  assert_eq(ecm(8051), [(83, 1), (97, 1)])
  assert_eq(qs(10403), [(101, 1), (103, 1)])
  assert_eq(qs(169), [(13, 2)])
}

///|
test "nt_prime_factors factorizes integers" {
  let factors = nt_prime_factors(84)
  assert_eq(factors, [(2, 2), (3, 1), (7, 1)])
  let negative = nt_prime_factors(-45)
  assert_eq(negative, [(3, 2), (5, 1)])
  let large = nt_prime_factors(360360)
  assert_eq(large, [(2, 3), (3, 2), (5, 1), (7, 1), (11, 1), (13, 1)])
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
test "factorization properties hold" {
  let n = 7560
  let pairs = nt_prime_factors(n)
  let mut product = 1
  let mut divisor_count = 1
  for pair in pairs {
    let (p, count) = pair
    let mut i = 0
    while i < count {
      product = product * p
      i += 1
    }
    divisor_count = divisor_count * (count + 1)
  }
  assert_eq(product, n)
  assert_eq(nt_divisor_count(n), divisor_count)
  assert_eq(nt_prime_factor_list(n).length(), primeomega(n))
  assert_eq(primefactors(n).length(), primenu(n))
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
  let f0 = nt_factorint(0)
  let mut entries0 = 0
  for _ in f0 {
    entries0 += 1
  }
  assert_eq(entries0, 0)
  let f1 = nt_factorint(1)
  let mut entries1 = 0
  for _ in f1 {
    entries1 += 1
  }
  assert_eq(entries1, 0)
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
  assert_eq(nt_divisor_count(360), 24)
  assert_eq(nt_divisor_sigma(360), 1170)
  assert_eq(nt_divisor_sigma(360, power=2), 201110)
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
test "negative inputs normalize to absolute value where applicable" {
  assert_eq(divisors(-12), [1, 2, 3, 4, 6, 12])
  assert_eq(divisor_sigma(-12), 28)
  assert_eq(carmichael(-15), 4)
  assert_eq(primefactors(-84), [2, 3, 7])
  assert_eq(totient(-9), 0)
}

///|
test "nt_totient matches known values" {
  assert_eq(nt_totient(1), 1)
  assert_eq(nt_totient(0), 0)
  assert_eq(nt_totient(-9), 0)
  assert_eq(nt_totient(9), 6)
  assert_eq(nt_totient(36), 12)
  assert_eq(nt_totient(360360), 69120)
}

///|
test "carmichael function computes lambda" {
  assert_eq(carmichael(1), 1)
  assert_eq(carmichael(2), 1)
  assert_eq(carmichael(4), 2)
  assert_eq(carmichael(8), 2)
  assert_eq(carmichael(16), 4)
  assert_eq(carmichael(9), 6)
  assert_eq(carmichael(45), 12)
  assert_eq(carmichael(561), 80)
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

///|
test "pollard_rho finds factors for semiprimes" {
  assert_eq(pollard_rho(8051), [(83, 1), (97, 1)])
  assert_eq(pollard_rho(10403), [(101, 1), (103, 1)])
  assert_eq(pollard_rho(169), [(13, 2)])
  assert_eq(pollard_rho(1022117), [(1009, 1), (1013, 1)])
  assert_eq(pollard_rho(13), [(13, 1)])
  assert_eq(pollard_rho(-45), [(3, 2), (5, 1)])
}

///|
test "pollard_pm1 handles smooth cases" {
  assert_eq(pollard_pm1(91), [(7, 1), (13, 1)])
  assert_eq(pollard_pm1(187), [(11, 1), (17, 1)])
  assert_eq(pollard_pm1(-91), [(7, 1), (13, 1)])
}

///|
test "pow_mod_int handles sign and modulus" {
  assert_eq(pow_mod_int(-2, 5, 13), 7)
  assert_eq(pow_mod_int(3, 4, -5), 1)
  assert_eq(pow_mod_int(2, 0, 5), 1)
}

///|
test "panic nt_divisor_sigma with negative power" {
  ignore(nt_divisor_sigma(12, power=-1))
}

///|
test "panic pow_mod_int with negative exponent" {
  ignore(pow_mod_int(2, -1, 7))
}

///|
test "panic abs_int with int min value" {
  ignore(abs_int(@int.min_value))
}
