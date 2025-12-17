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
