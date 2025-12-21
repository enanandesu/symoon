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
  let mut value = if n < 0 { -n } else { n }
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
  let factors = nt_prime_factors(if n < 0 { -n } else { n })
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
  let factors = nt_prime_factors(if n < 0 { -n } else { n })
  factors.length()
}

///|
pub fn primeomega(n : Int) -> Int {
  if n == 0 {
    return 0
  }
  let factors = nt_prime_factors(if n < 0 { -n } else { n })
  let mut total = 0
  for pair in factors {
    let (_, count) = pair
    total += count
  }
  total
}

///|
pub fn carmichael(n : Int) -> Int {
  if n == 0 {
    return 0
  }
  if n == 1 {
    return 1
  }
  let factors = nt_prime_factors(if n < 0 { -n } else { n })
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
  let value = if n < 0 { -n } else { n }
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
  let value = if n < 0 { -n } else { n }
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
  let value = if n < 0 { -n } else { n }
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
