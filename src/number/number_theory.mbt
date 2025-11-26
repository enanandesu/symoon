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
pub fn nt_gcd_ex(a : Int, b : Int) -> (Int, Int, Int) {
  if a == 0 && b == 0 {
    return (0, 0, 0)
  }
  let mut old_r = a
  let mut r = b
  let mut old_s = 1
  let mut s = 0
  let mut old_t = 0
  let mut t = 1
  while r != 0 {
    let q = old_r / r
    let temp_r = old_r - q * r
    old_r = r
    r = temp_r
    let temp_s = old_s - q * s
    old_s = s
    s = temp_s
    let temp_t = old_t - q * t
    old_t = t
    t = temp_t
  }
  let mut g = old_r
  if g < 0 {
    g = -g
    old_s = -old_s
    old_t = -old_t
  }
  (old_s, old_t, g)
}

///|
fn mod_inverse_internal(a : Int, modulus : Int) -> (Bool, Int) {
  if modulus == 0 {
    return (false, 0)
  }
  let mut m = modulus
  if m < 0 {
    m = -m
  }
  let (_, t, g) = nt_gcd_ex(m, a % m)
  if g != 1 {
    return (false, 0)
  }
  let mut inv = t % m
  if inv < 0 {
    inv += m
  }
  (true, inv)
}

///|
pub fn gcd(a : Int, b : Int) -> Int {
  nt_gcd(a, b)
}

///|
pub fn igcd(a : Int, b : Int) -> Int {
  nt_gcd(a, b)
}

///|
pub fn lcm(a : Int, b : Int) -> Int {
  nt_lcm(a, b)
}

///|
pub fn ilcm(a : Int, b : Int) -> Int {
  nt_lcm(a, b)
}

///|
pub fn gcdex(a : Int, b : Int) -> (Int, Int, Int) {
  nt_gcd_ex(a, b)
}

///|
pub fn mod_inverse(a : Int, modulus : Int) -> Int {
  let (ok, inv) = mod_inverse_internal(a, modulus)
  if ok {
    inv
  } else {
    0
  }
}

///|
pub fn nt_is_divisible_by(n : Int, divisor : Int) -> Bool {
  if divisor == 0 {
    return false
  }
  n % divisor == 0
}

///|
pub fn nt_is_divisible_by_all(n : Int, divisors : Array[Int]) -> Bool {
  let len = divisors.length()
  let mut i = 0
  while i < len {
    if !nt_is_divisible_by(n, divisors[i]) {
      return false
    }
    i += 1
  }
  true
}

///|
pub fn nt_is_divisible_by_any(n : Int, divisors : Array[Int]) -> Bool {
  let len = divisors.length()
  let mut i = 0
  while i < len {
    if nt_is_divisible_by(n, divisors[i]) {
      return true
    }
    i += 1
  }
  false
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
pub fn nt_prime_pi(limit : Int) -> Int {
  if limit < 2 {
    return 0
  }
  let primes = nt_primes_up_to(limit)
  primes.length()
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
pub fn nt_factorint(n : Int) -> Array[(Int, Int)] {
  nt_prime_factors(n)
}

///|
pub fn factorint(n : Int) -> Array[(Int, Int)] {
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
fn pow_mod(base : Int, exp : Int, modulus : Int) -> Int {
  if modulus == 0 {
    return 0
  }
  let mut m = modulus
  if m < 0 {
    m = -m
  }
  let mut b = (base % m + m) % m
  let mut e = exp
  if e < 0 {
    abort("exponent must be non-negative")
  }
  let mut result = 1 % m
  while e > 0 {
    if e % 2 == 1 {
      result = result * b % m
    }
    b = b * b % m
    e = e / 2
  }
  result
}

///|
pub fn sqrt_mod(n : Int, modulus : Int) -> Array[Int] {
  let roots = Array::new()
  if modulus <= 0 {
    return roots
  }
  let target = (n % modulus + modulus) % modulus
  let mut x = 0
  while x < modulus {
    if x * x % modulus == target {
      roots.push(x)
    }
    x += 1
  }
  roots
}

///|
pub fn quadratic_residues(modulus : Int) -> Array[Int] {
  let residues = Array::new()
  if modulus <= 0 {
    return residues
  }
  let seen : Map[Int, Bool] = {}
  let mut x = 0
  while x < modulus {
    let value = x * x % modulus
    match seen.get(value) {
      Some(_) => ()
      None => {
        seen.set(value, true)
        residues.push(value)
      }
    }
    x += 1
  }
  sort_ints(residues)
}

///|
pub fn legendre_symbol(a : Int, p : Int) -> Int {
  if p <= 2 || !nt_is_prime(p) {
    return 0
  }
  let value = (a % p + p) % p
  if value == 0 {
    return 0
  }
  let result = pow_mod(value, (p - 1) / 2, p)
  if result == 1 {
    1
  } else if result == p - 1 {
    -1
  } else {
    0
  }
}

///|
pub fn jacobi_symbol(a : Int, n : Int) -> Int {
  if n <= 0 || n % 2 == 0 {
    return 0
  }
  let mut aa = a
  let mut nn = n
  let mut result = 1
  aa = (aa % nn + nn) % nn
  while aa != 0 {
    let mut t = 0
    while aa % 2 == 0 {
      aa = aa / 2
      t += 1
    }
    if t % 2 == 1 {
      let r = nn % 8
      if r == 3 || r == 5 {
        result = -result
      }
    }
    if aa % 4 == 3 && nn % 4 == 3 {
      result = -result
    }
    let temp = aa
    aa = nn % aa
    nn = temp
  }
  if nn == 1 {
    result
  } else {
    0
  }
}

///|
pub fn is_quad_residue(a : Int, modulus : Int) -> Bool {
  if modulus <= 0 {
    return false
  }
  let roots = sqrt_mod(a, modulus)
  roots.length() > 0
}

///|
pub fn solve_congruence(congruences : Array[(Int, Int)]) -> (Int, Int) {
  let count = congruences.length()
  if count == 0 {
    return (0, 0)
  }
  let (r0, m0) = congruences[0]
  let mut x = r0
  let mut modulus = m0
  if modulus < 0 {
    modulus = -modulus
  }
  if modulus == 0 {
    return (0, 0)
  }
  let mut i = 1
  while i < count {
    let (ri_raw, mi_raw) = congruences[i]
    let mut mi = mi_raw
    if mi < 0 {
      mi = -mi
    }
    if mi == 0 {
      return (0, 0)
    }
    let ri = (ri_raw % mi + mi) % mi
    let mut current_x = (x % modulus + modulus) % modulus
    let g = nt_gcd(modulus, mi)
    if (ri - current_x) % g != 0 {
      return (0, 0)
    }
    let lcm = modulus / g * mi
    let m1 = modulus / g
    let m2 = mi / g
    let rhs = (ri - current_x) / g
    let (ok, inv) = mod_inverse_internal(m1 % m2, m2)
    if !ok {
      return (0, 0)
    }
    let k = rhs * inv % m2
    current_x = current_x + modulus * k
    x = (current_x % lcm + lcm) % lcm
    modulus = lcm
    i += 1
  }
  (x, modulus)
}

///|
fn pow_int(base : Int, exp : Int) -> Int {
  if exp < 0 {
    abort("exponent must be non-negative")
  }
  let mut result = 1
  let mut i = 0
  while i < exp {
    result = result * base
    i += 1
  }
  result
}

///|
fn sort_ints(values : Array[Int]) -> Array[Int] {
  let len = values.length()
  let mut i = 0
  while i < len {
    let mut min_index = i
    let mut j = i + 1
    while j < len {
      if values[j] < values[min_index] {
        min_index = j
      }
      j += 1
    }
    if min_index != i {
      let temp = values[i]
      values[i] = values[min_index]
      values[min_index] = temp
    }
    i += 1
  }
  values
}
