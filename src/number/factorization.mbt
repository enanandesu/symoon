///|
pub fn nt_prime_factors(n : Int) -> Array[(Int, Int)] {
  let mut value = abs_int(n)
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
  while p <= value / p {
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
pub fn nt_factorint(n : Int) -> Map[Int, Int] {
  let pairs = nt_prime_factors(n)
  let factors : Map[Int, Int] = {}
  for pair in pairs {
    let (prime, count) = pair
    factors.set(prime, count)
  }
  factors
}

///|
pub fn factorint(n : Int) -> Map[Int, Int] {
  nt_factorint(n)
}

///|
pub fn nt_multiplicity(prime : Int, n : Int) -> Int {
  if prime <= 1 {
    return 0
  }
  let mut value = abs_int(n)
  if value == 0 {
    return 0
  }
  let mut count = 0
  while value % prime == 0 {
    value = value / prime
    count += 1
  }
  count
}

///|
pub fn multiplicity(prime : Int, n : Int) -> Int {
  nt_multiplicity(prime, n)
}

///|
pub fn nt_prime_factor_list(n : Int) -> Array[Int] {
  let pairs = nt_prime_factors(n)
  let factors = Array::new()
  for pair in pairs {
    let (prime, count) = pair
    let mut i = 0
    while i < count {
      factors.push(prime)
      i += 1
    }
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

///|
pub fn totient(n : Int) -> Int {
  nt_totient(n)
}

///|
pub fn mobius(n : Int) -> Int {
  if n == 0 {
    return 0
  }
  let mut result = 1
  let factors = nt_prime_factors(abs_int(n))
  for pair in factors {
    let (_, count) = pair
    if count > 1 {
      return 0
    }
    result = -result
  }
  if n < 0 {
    result = -result
  }
  result
}

///|
pub fn primenu(n : Int) -> Int {
  if n == 0 {
    return 0
  }
  let factors = nt_prime_factors(abs_int(n))
  factors.length()
}

///|
pub fn primeomega(n : Int) -> Int {
  if n == 0 {
    return 0
  }
  let factors = nt_prime_factors(abs_int(n))
  let mut total = 0
  for pair in factors {
    let (_, count) = pair
    total += count
  }
  total
}

///|
pub fn primefactors(n : Int) -> Array[Int] {
  let factors = nt_prime_factors(n)
  let unique = Array::new()
  for pair in factors {
    let (p, _) = pair
    unique.push(p)
  }
  unique
}

///|
pub fn perfect_power(n : Int) -> Bool {
  if n == 0 || n == 1 || n == -1 {
    return true
  }
  let absn = abs_int(n)
  let limit = int_sqrt(absn)
  let mut base = 2
  while base <= limit {
    let mut value = base
    let mut exp = 1
    while value <= absn / base {
      value = value * base
      exp += 1
      if value == absn {
        if n < 0 && exp % 2 == 0 {
          break
        }
        return true
      }
    }
    base += 1
  }
  false
}

///|
pub fn trailing(n : Int) -> Int {
  nt_multiplicity(2, n)
}

///|
fn abs_int(value : Int) -> Int {
  let abs_value = value.abs()
  if abs_value < 0 {
    abort("abs overflow")
  }
  abs_value
}

///|
fn add_mod(a : Int, b : Int, modulus : Int) -> Int {
  if a >= modulus - b {
    a - (modulus - b)
  } else {
    a + b
  }
}

///|
fn mul_mod(a : Int, b : Int, modulus : Int) -> Int {
  let mut result = 0
  let mut x = a % modulus
  if x < 0 {
    x = x + modulus
  }
  let mut y = b
  if y < 0 {
    y = -y
  }
  while y > 0 {
    if y % 2 == 1 {
      result = add_mod(result, x, modulus)
    }
    y = y / 2
    if y > 0 {
      x = add_mod(x, x, modulus)
    }
  }
  result
}

///|
fn pow_mod_int(base : Int, exp : Int, modulus : Int) -> Int {
  if modulus == 0 {
    return 0
  }
  let m = abs_int(modulus)
  let mut b = base % m
  if b < 0 {
    b = b + m
  }
  let mut e = exp
  if e < 0 {
    abort("exponent must be non-negative")
  }
  let mut result = 1 % m
  while e > 0 {
    if e % 2 == 1 {
      result = mul_mod(result, b, m)
    }
    b = mul_mod(b, b, m)
    e = e / 2
  }
  result
}

///|
fn rho_factor(n : Int) -> Int {
  if n % 2 == 0 {
    return 2
  }
  let mut c = 1
  while c <= 9 {
    let mut x = 2
    let mut y = 2
    let mut d = 1
    let mut iter = 0
    while d == 1 && iter < 10000 {
      x = (mul_mod(x, x, n) + c) % n
      y = (mul_mod(y, y, n) + c) % n
      y = (mul_mod(y, y, n) + c) % n
      let diff = if x > y { x - y } else { y - x }
      d = nt_gcd(diff, n)
      iter += 1
    }
    if d > 1 && d < n {
      return d
    }
    c += 1
  }
  0
}

///|
fn pm1_factor(n : Int) -> Int {
  if n % 2 == 0 {
    return 2
  }
  let bounds = [10, 20, 50, 100, 200, 500, 1000]
  for bound in bounds {
    let mut a = 2
    let mut j = 2
    while j <= bound {
      a = pow_mod_int(a, j, n)
      j += 1
    }
    let diff = abs_int(a - 1)
    let d = nt_gcd(diff, n)
    if d > 1 && d < n {
      return d
    }
  }
  0
}

///|
fn factor_with(n : Int, algo : (Int) -> Int) -> Array[(Int, Int)] {
  let value = abs_int(n)
  let factors = Array::new()
  fn push_factor_list(
    value : Int,
    factors : Array[Int],
    algo : (Int) -> Int,
  ) -> Unit {
    if value <= 1 {
      return ()
    }
    if nt_is_prime(value) {
      factors.push(value)
      return ()
    }
    let small_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    for p in small_primes {
      if value % p == 0 {
        factors.push(p)
        push_factor_list(value / p, factors, algo)
        return ()
      }
    }
    let factor = abs_int(algo(value))
    if factor == 0 || factor == value {
      let pairs = nt_prime_factors(value)
      for pair in pairs {
        let (p, count) = pair
        let mut i = 0
        while i < count {
          factors.push(p)
          i += 1
        }
      }
      return ()
    }
    push_factor_list(factor, factors, algo)
    push_factor_list(value / factor, factors, algo)
  }

  push_factor_list(value, factors, algo)
  if factors.length() == 0 {
    return Array::new()
  }
  let sorted = sort_ints(factors)
  let pairs = Array::new()
  let mut i = 0
  let len = sorted.length()
  while i < len {
    let p = sorted[i]
    let mut count = 1
    let mut j = i + 1
    while j < len && sorted[j] == p {
      count += 1
      j += 1
    }
    pairs.push((p, count))
    i = j
  }
  pairs
}

///|
pub fn pollard_rho(n : Int) -> Array[(Int, Int)] {
  factor_with(n, rho_factor)
}

///|
pub fn pollard_pm1(n : Int) -> Array[(Int, Int)] {
  factor_with(n, pm1_factor)
}

///|
pub fn ecm(n : Int) -> Array[(Int, Int)] {
  nt_prime_factors(n)
}

///|
pub fn qs(n : Int) -> Array[(Int, Int)] {
  nt_prime_factors(n)
}

///|
pub fn carmichael(n : Int) -> Int {
  if n == 0 {
    return 0
  }
  if n == 1 {
    return 1
  }
  let factors = nt_prime_factors(abs_int(n))
  let mut result = 1
  for pair in factors {
    let (p, k) = pair
    let lambda_p = if p == 2 {
      if k == 1 {
        1
      } else if k == 2 {
        2
      } else {
        pow_int(2, k - 2)
      }
    } else {
      (p - 1) * pow_int(p, k - 1)
    }
    result = nt_lcm(result, lambda_p)
  }
  result
}

///|
pub fn nt_divisors(n : Int) -> Array[Int] {
  let value = abs_int(n)
  let divisors = Array::new()
  if value == 0 {
    return divisors
  }
  divisors.push(1)
  let pairs = nt_prime_factors(value)
  for pair in pairs {
    let (prime, count) = pair
    let current_len = divisors.length()
    let mut i = 0
    while i < current_len {
      let base = divisors[i]
      let mut power = 1
      let mut exp = 0
      while exp < count {
        power = power * prime
        divisors.push(base * power)
        exp += 1
      }
      i += 1
    }
  }
  sort_ints(divisors)
}

///|
pub fn nt_divisor_count(n : Int) -> Int {
  let value = abs_int(n)
  if value == 0 {
    return 0
  }
  let pairs = nt_prime_factors(value)
  let mut total = 1
  for pair in pairs {
    let (_, count) = pair
    total = total * (count + 1)
  }
  total
}

///|
pub fn nt_divisor_sigma(n : Int, power? : Int = 1) -> Int {
  if power < 0 {
    abort("power must be non-negative")
  }
  let value = abs_int(n)
  if value == 0 {
    return 0
  }
  if value == 1 {
    return 1
  }
  if power == 0 {
    return nt_divisor_count(value)
  }
  let pairs = nt_prime_factors(value)
  let mut total = 1
  for pair in pairs {
    let (prime, count) = pair
    let numerator = pow_int(prime, (count + 1) * power) - 1
    let denominator = pow_int(prime, power) - 1
    total = total * numerator / denominator
  }
  total
}

///|
pub fn divisors(n : Int) -> Array[Int] {
  nt_divisors(n)
}

///|
pub fn divisor_count(n : Int) -> Int {
  nt_divisor_count(n)
}

///|
pub fn divisor_sigma(n : Int, power? : Int = 1) -> Int {
  nt_divisor_sigma(n, power~)
}

///|
pub fn sum_of_squares(n : Int) -> Int {
  if n < 0 {
    return 0
  }
  if n == 0 {
    return 1
  }
  let factors = nt_prime_factors(n)
  for pair in factors {
    let (p, count) = pair
    if p % 4 == 3 && count % 2 == 1 {
      return 0
    }
  }
  1
}
