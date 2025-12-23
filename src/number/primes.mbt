///|
pub fn nt_is_prime(n : Int) -> Bool {
  if n <= 1 {
    return false
  }
  if n <= 3 {
    return true
  }
  if n % 2 == 0 || n % 3 == 0 {
    return false
  }
  let mut i = 5
  while i <= n / i {
    if n % i == 0 || n % (i + 2) == 0 {
      return false
    }
    i += 6
  }
  true
}

///|
pub fn isprime(n : Int) -> Bool {
  nt_is_prime(n)
}

///|
pub fn nt_primes_up_to(limit : Int) -> Array[Int] {
  let primes = Array::new()
  if limit < 2 {
    return primes
  }
  let mut n = 2
  while n <= limit {
    if nt_is_prime(n) {
      primes.push(n)
    }
    n += 1
  }
  primes
}

///|
pub fn nt_first_n_primes(count : Int) -> Array[Int] {
  let primes = Array::new()
  if count <= 0 {
    return primes
  }
  let mut candidate = 2
  while primes.length() < count {
    if nt_is_prime(candidate) {
      primes.push(candidate)
    }
    candidate += 1
  }
  primes
}

///|
pub fn nt_nth_prime(index : Int) -> Int {
  if index <= 0 {
    return 0
  }
  let mut candidate = 2
  let mut count = 0
  while true {
    if nt_is_prime(candidate) {
      count += 1
      if count == index {
        return candidate
      }
    }
    candidate += 1
  }
  abort("unreachable")
}

///|
pub fn nt_prime(index : Int) -> Int {
  nt_nth_prime(index)
}

///|
pub fn prime(index : Int) -> Int {
  nt_prime(index)
}

///|
pub fn nt_prime_pi(limit : Int) -> Int {
  if limit < 2 {
    return 0
  }
  let primes = nt_primes_up_to(limit)
  primes.length()
}

///|
pub fn primepi(limit : Int) -> Int {
  nt_prime_pi(limit)
}

///|
pub fn nt_next_prime(n : Int) -> Int {
  let mut candidate = if n < 1 { 2 } else { n + 1 }
  while true {
    if nt_is_prime(candidate) {
      return candidate
    }
    candidate += 1
  }
  abort("unreachable")
}

///|
pub fn nt_prev_prime(n : Int) -> Int {
  let mut candidate = n - 1
  while candidate >= 2 {
    if nt_is_prime(candidate) {
      return candidate
    }
    candidate -= 1
  }
  0
}

///|
pub fn nextprime(n : Int) -> Int {
  nt_next_prime(n)
}

///|
pub fn prevprime(n : Int) -> Int {
  nt_prev_prime(n)
}

///|
pub fn nt_prime_range(start : Int, end : Int) -> Array[Int] {
  let primes = Array::new()
  if end <= start {
    return primes
  }
  let mut candidate = if start < 2 { 2 } else { start }
  while candidate < end {
    if nt_is_prime(candidate) {
      primes.push(candidate)
    }
    candidate += 1
  }
  primes
}

///|
pub fn primerange(start : Int, end : Int) -> Array[Int] {
  nt_prime_range(start, end)
}

///|
pub fn nt_rand_prime(start : Int, end : Int, seed? : Int = 0) -> Int {
  let primes = nt_prime_range(start, end)
  let count = primes.length()
  if count == 0 {
    return 0
  }
  let mut basis = if seed != 0 { seed } else { start + end + count }
  if basis < 0 {
    basis = -basis
  }
  primes[basis % count]
}

///|
pub fn randprime(start : Int, end : Int, seed? : Int = 0) -> Int {
  nt_rand_prime(start, end, seed~)
}

///|
pub fn primorial(n : Int, nth? : Bool = true) -> Int {
  if n <= 0 {
    return 1
  }
  let primes = if nth { nt_first_n_primes(n) } else { nt_primes_up_to(n) }
  let mut result = 1
  for p in primes {
    result = result * p
  }
  result
}

///|
pub fn compositepi(n : Int) -> Int {
  if n <= 4 {
    return 0
  }
  let limit = n - 1
  let primes = nt_prime_pi(limit)
  let count_non_primes = limit - 1 - primes
  if count_non_primes < 0 {
    0
  } else {
    count_non_primes
  }
}

///|
pub fn composite(n : Int) -> Int {
  if n <= 0 {
    return 0
  }
  let mut count = 0
  let mut x = 4
  while true {
    if !nt_is_prime(x) {
      count += 1
      if count == n {
        return x
      }
    }
    x += 1
  }
  abort("unreachable")
}

///|
pub fn compositepi_alt(n : Int) -> Int {
  compositepi(n)
}

///|
pub struct Sieve {
  primes : Array[Int]
  limit : Int
}

///|
pub fn Sieve::new() -> Sieve {
  Sieve::{ primes: Array::new(), limit: 1 }
}

///|
pub fn Sieve::extend(self : Sieve, n : Int) -> Sieve {
  if n <= self.limit {
    return self
  }
  let primes = self.primes
  let mut current = self.limit + 1
  if current < 2 {
    current = 2
  }
  while current <= n {
    if nt_is_prime(current) {
      primes.push(current)
    }
    current += 1
  }
  Sieve::{ primes, limit: n }
}

///|
pub fn Sieve::primerange(self : Sieve, start : Int, end : Int) -> Array[Int] {
  let mut s = self
  if end > s.limit {
    s = s.extend(end)
  }
  let primes = nt_prime_range(start, end)
  primes
}

///|
pub fn Sieve::primes(self : Sieve) -> Array[Int] {
  self.primes
}
