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
