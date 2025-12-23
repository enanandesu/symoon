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
pub fn mod_inverse(a : Int, modulus : Int) -> Int {
  let (ok, inv) = mod_inverse_internal(a, modulus)
  if ok {
    inv
  } else {
    0
  }
}

///|
pub fn invert(a : Int, modulus : Int) -> Int {
  mod_inverse(a, modulus)
}

///|
pub fn crt1(mods : Array[Int]) -> (Int, Array[Int], Array[Int]) {
  let normalized = Array::new()
  let count = mods.length()
  if count == 0 {
    return (0, Array::new(), Array::new())
  }
  let mut modulus = 1
  let mut i = 0
  while i < count {
    let mut m = mods[i]
    if m < 0 {
      m = -m
    }
    if m == 0 {
      return (0, Array::new(), Array::new())
    }
    normalized.push(m)
    modulus = modulus * m
    i += 1
  }
  let e = Array::new()
  let s = Array::new()
  for m in normalized {
    let ei = modulus / m
    let (ok, inv) = mod_inverse_internal(ei % m, m)
    if !ok {
      return (0, Array::new(), Array::new())
    }
    e.push(ei)
    s.push(inv)
  }
  (modulus, e, s)
}

///|
pub fn crt2(
  mods : Array[Int],
  residues : Array[Int],
  mm : Int,
  e : Array[Int],
  s : Array[Int],
  symmetric? : Bool = false,
) -> (Int, Int) {
  let count = mods.length()
  if count == 0 ||
    count != residues.length() ||
    count != e.length() ||
    count != s.length() ||
    mm == 0 {
    return (0, 0)
  }
  let mut total = 0
  let mut i = 0
  while i < count {
    let mut m = mods[i]
    if m < 0 {
      m = -m
    }
    if m == 0 {
      return (0, 0)
    }
    let mut r = residues[i] % m
    if r < 0 {
      r += m
    }
    total = total + e[i] * (r * s[i] % m)
    i += 1
  }
  let mut result = total % mm
  if result < 0 {
    result += mm
  }
  if symmetric && result > mm / 2 {
    result = result - mm
  }
  (result, mm)
}

///|
pub fn crt(
  mods : Array[Int],
  residues : Array[Int],
  symmetric? : Bool = false,
  check? : Bool = true,
) -> (Int, Int) {
  let count = mods.length()
  if count == 0 || count != residues.length() {
    return (0, 0)
  }
  let (mm, e, s) = crt1(mods)
  if mm != 0 {
    let (value, modulus) = crt2(mods, residues, mm, e, s, symmetric~)
    if modulus != 0 {
      if !check {
        return (value, modulus)
      }
      let mut ok = true
      let mut i = 0
      while i < count {
        let mut m = mods[i]
        if m < 0 {
          m = -m
        }
        if m == 0 {
          ok = false
          break
        }
        let mut r = residues[i] % m
        if r < 0 {
          r += m
        }
        let mut v = value % m
        if v < 0 {
          v += m
        }
        if v != r {
          ok = false
          break
        }
        i += 1
      }
      if ok {
        return (value, modulus)
      }
    }
  }
  let pairs = Array::new()
  let mut i = 0
  while i < count {
    pairs.push((residues[i], mods[i]))
    i += 1
  }
  let (value, modulus) = solve_congruence(pairs)
  if modulus == 0 {
    return (0, 0)
  }
  let mut result = value
  if symmetric && result > modulus / 2 {
    result = result - modulus
  }
  (result, modulus)
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
pub fn sqrt_mod_iter(n : Int, modulus : Int) -> Array[Int] {
  sqrt_mod(n, modulus)
}

///|
pub fn nthroot_mod(a : Int, n : Int, modulus : Int) -> Array[Int] {
  let roots = Array::new()
  if modulus <= 0 || n <= 0 {
    return roots
  }
  let mut m = modulus
  if m < 0 {
    m = -m
  }
  let mut target = a % m
  if target < 0 {
    target += m
  }
  let mut x = 0
  while x < m {
    if pow_mod(x, n, m) == target {
      roots.push(x)
    }
    x += 1
  }
  roots
}

///|
pub fn discrete_log(
  modulus : Int,
  base : Int,
  value : Int,
  order? : Int = 0,
) -> Int {
  let mut n = modulus
  if n == 0 {
    return -1
  }
  if n < 0 {
    n = -n
  }
  if n == 1 {
    return 0
  }
  let mut g = base % n
  if g < 0 {
    g += n
  }
  let mut h = value % n
  if h < 0 {
    h += n
  }
  if h == 1 % n {
    return 0
  }
  let mut bound = order
  if bound <= 0 {
    if nt_gcd(g, n) == 1 {
      bound = nt_totient(n)
    } else {
      bound = n
    }
  }
  if bound <= 0 {
    return -1
  }
  if nt_gcd(g, n) != 1 {
    let mut x = 0
    let mut cur = 1 % n
    while x <= bound {
      if cur == h {
        return x
      }
      cur = cur * g % n
      x += 1
    }
    return -1
  }
  let m = int_sqrt(bound) + 1
  let table : Map[Int, Int] = {}
  let mut baby = 1 % n
  let mut j = 0
  while j < m {
    match table.get(baby) {
      Some(_) => ()
      None => table.set(baby, j)
    }
    baby = baby * g % n
    j += 1
  }
  let (ok, inv) = mod_inverse_internal(g, n)
  if !ok {
    return -1
  }
  let factor = pow_mod(inv, m, n)
  let mut giant = h
  let mut i = 0
  while i <= m {
    match table.get(giant) {
      Some(jval) => {
        let x = i * m + jval
        if x <= bound {
          return x
        }
      }
      None => ()
    }
    giant = giant * factor % n
    i += 1
  }
  -1
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
pub fn kronecker_symbol(a : Int, n : Int) -> Int {
  if n == 0 {
    return if a == 1 || a == -1 { 1 } else { 0 }
  }
  if n == 1 {
    return 1
  }
  let mut value = n
  let mut result = 1
  if value < 0 {
    value = -value
    if a < 0 {
      result = -result
    }
  }
  let mut nn = value
  while nn % 2 == 0 {
    let a_mod8 = (a % 8 + 8) % 8
    if a_mod8 == 3 || a_mod8 == 5 {
      result = -result
    }
    nn = nn / 2
  }
  if nn == 1 {
    return result
  }
  let jac = jacobi_symbol(a, nn)
  if jac == 0 {
    0
  } else {
    result * jac
  }
}

///|
pub fn n_order(a : Int, n : Int) -> Int {
  if n <= 0 {
    return 0
  }
  if nt_gcd(a, n) != 1 {
    return 0
  }
  let phi = nt_totient(n)
  let factors = nt_prime_factors(phi)
  let mut order = phi
  for pair in factors {
    let (p, count) = pair
    let mut i = 0
    while i < count && order % p == 0 {
      let candidate = order / p
      if pow_mod(a, candidate, n) == 1 {
        order = candidate
      } else {
        break
      }
      i += 1
    }
  }
  order
}

///|
pub fn is_primitive_root(a : Int, n : Int) -> Bool {
  let mut modulus = n
  if modulus < 0 {
    modulus = -modulus
  }
  if modulus <= 1 {
    return false
  }
  let mut g = a % modulus
  if g < 0 {
    g += modulus
  }
  if nt_gcd(g, modulus) != 1 {
    return false
  }
  let phi = nt_totient(modulus)
  if phi == 0 {
    return false
  }
  let factors = nt_prime_factors(phi)
  for pair in factors {
    let (p, _) = pair
    if pow_mod(g, phi / p, modulus) == 1 {
      return false
    }
  }
  true
}

///|
pub fn primitive_root(n : Int) -> Int {
  let mut modulus = n
  if modulus < 0 {
    modulus = -modulus
  }
  if modulus == 2 {
    return 1
  }
  if modulus <= 1 {
    return 0
  }
  let phi = nt_totient(modulus)
  if phi == 0 {
    return 0
  }
  let factors = nt_prime_factors(phi)
  let mut g = 2
  while g < modulus {
    if nt_gcd(g, modulus) == 1 {
      let mut ok = true
      for pair in factors {
        let (p, _) = pair
        if pow_mod(g, phi / p, modulus) == 1 {
          ok = false
          break
        }
      }
      if ok {
        return g
      }
    }
    g += 1
  }
  0
}
