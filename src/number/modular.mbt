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
