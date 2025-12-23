///|
test "nt_is_prime checks small and composite numbers" {
  assert_eq(nt_is_prime(1), false)
  assert_eq(nt_is_prime(2), true)
  assert_eq(nt_is_prime(17), true)
  assert_eq(nt_is_prime(21), false)
}

///|
test "nt_is_prime handles larger primes and Carmichael numbers" {
  assert_eq(nt_is_prime(-7), false)
  assert_eq(nt_is_prime(0), false)
  assert_eq(nt_is_prime(2147483647), true)
  assert_eq(nt_is_prime(2147483645), false)
  assert_eq(nt_is_prime(561), false)
  assert_eq(nt_is_prime(1105), false)
  assert_eq(nt_is_prime(1729), false)
  assert_eq(nt_is_prime(2465), false)
  assert_eq(nt_is_prime(2821), false)
  assert_eq(nt_is_prime(6601), false)
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
test "prime helpers aliases" {
  assert_eq(isprime(17), true)
  assert_eq(isprime(1), false)
  assert_eq(isprime(2147483647), true)
  assert_eq(isprime(561), false)
  assert_eq(prime(6), 13)
  assert_eq(prime(0), 0)
  assert_eq(primepi(10), 4)
  assert_eq(primepi(100), 25)
  let range = primerange(10, 20)
  assert_eq(range, [11, 13, 17, 19])
  let small = primerange(-5, 5)
  assert_eq(small, [2, 3])
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
test "nextprime and prevprime aliases mirror nt versions" {
  assert_eq(nextprime(50), 53)
  assert_eq(prevprime(50), 47)
  assert_eq(nextprime(-10), 2)
  assert_eq(prevprime(2), 0)
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
test "prime generation helpers" {
  assert_eq(prime(5), 11)
  assert_eq(primepi(10), 4)
  let primes = primerange(10, 20)
  assert_eq(primes, [11, 13, 17, 19])
  let r = randprime(20, 30, seed=5)
  assert_eq(nt_is_prime(r), true)
  assert_eq(primorial(5), 2310)
  assert_eq(primorial(5, nth=false), 30)
}

///|
test "composite counting and nth composite" {
  assert_eq(compositepi(10), 4)
  assert_eq(composite(1), 4)
  assert_eq(composite(5), 10)
}

///|
test "sieve basic usage" {
  let s = Sieve::new().extend(20)
  let plist = s.primerange(2, 15)
  assert_eq(plist, [2, 3, 5, 7, 11, 13])
}
