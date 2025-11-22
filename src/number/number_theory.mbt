///|
pub fn nt_gcd(a : Int, b : Int) -> Int {
  let mut x = if a < 0 { -a } else { a }
  let mut y = if b < 0 { -b } else { b }
  while y != 0 {
    let temp = y
    y = x % y
    x = temp
  }
  x
}

///|
pub fn nt_lcm(a : Int, b : Int) -> Int {
  if a == 0 || b == 0 {
    0
  } else {
    let g = nt_gcd(a, b)
    a / g * b
  }
}

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
pub fn nt_prime_factors(n : Int) -> Array[(Int, Int)] {
  let mut value = if n < 0 { -n } else { n }
  let factors = Array::new()
  if value <= 1 {
    return factors
  }
  let mut count = 0
  while value % 2 == 0 {
    value = value / 2
    count += 1
  }
  if count > 0 {
    factors.push((2, count))
  }
  let mut p = 3
  while p * p <= value {
    count = 0
    while value % p == 0 {
      value = value / p
      count += 1
    }
    if count > 0 {
      factors.push((p, count))
    }
    p += 2
  }
  if value > 1 {
    factors.push((value, 1))
  }
  factors
}

///|
pub fn nt_totient(n : Int) -> Int {
  if n <= 0 {
    return 0
  }
  let mut result = n
  let factors = nt_prime_factors(n)
  for item in factors {
    let (p, _) = item
    result = result / p * (p - 1)
  }
  result
}
