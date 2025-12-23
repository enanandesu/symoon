///|
fn floor_div(a : Int, b : Int) -> Int {
  if b <= 0 {
    return 0
  }
  if a >= 0 {
    a / b
  } else {
    -((-a + b - 1) / b)
  }
}

///|
pub fn continued_fraction_iterator(n : Int, d? : Int = 1) -> Array[Int] {
  let mut denom = d
  if denom == 0 {
    return Array::new()
  }
  let mut num = n
  if denom < 0 {
    denom = -denom
    num = -num
  }
  let cf = Array::new()
  let mut a_num = num
  let mut a_den = denom
  while true {
    let a = floor_div(a_num, a_den)
    cf.push(a)
    let r = a_num - a * a_den
    if r == 0 {
      break
    }
    a_num = a_den
    a_den = r
  }
  cf
}

///|
pub fn continued_fraction_periodic(
  p : Int,
  q : Int,
  d? : Int = 0,
  s? : Int = 1,
) -> (Array[Int], Array[Int]) {
  if q == 0 {
    return (Array::new(), Array::new())
  }
  if d < 0 {
    return (Array::new(), Array::new())
  }
  let mut pp = p
  let mut qq = q
  let mut ss = s
  let mut dd = d
  if ss == 0 {
    dd = 0
  }
  if ss < 0 {
    ss = -ss
    pp = -pp
    qq = -qq
  }
  if qq < 0 {
    qq = -qq
    pp = -pp
  }
  let d_scaled = dd * ss * ss
  let root = int_sqrt(d_scaled)
  if d_scaled == 0 || root * root == d_scaled {
    let num = pp + ss * root
    let cf = continued_fraction_iterator(num, d=qq)
    return (cf, Array::new())
  }
  let pre = Array::new()
  let a0 = floor_div(pp + root, qq)
  pre.push(a0)
  let mut p1 = a0 * qq - pp
  let mut q1 = (d_scaled - p1 * p1) / qq
  if q1 == 0 {
    return (pre, Array::new())
  }
  let p0 = p1
  let q0 = q1
  let period = Array::new()
  while true {
    let a = floor_div(p1 + root, q1)
    period.push(a)
    let next_p = a * q1 - p1
    let next_q = (d_scaled - next_p * next_p) / q1
    if next_p == p0 && next_q == q0 {
      break
    }
    p1 = next_p
    q1 = next_q
  }
  (pre, period)
}

///|
pub fn continued_fraction_convergents(cf : Array[Int]) -> Array[(Int, Int)] {
  let convergents = Array::new()
  if cf.length() == 0 {
    return convergents
  }
  let mut p0 = 0
  let mut p1 = 1
  let mut q0 = 1
  let mut q1 = 0
  for a in cf {
    let p = a * p1 + p0
    let q = a * q1 + q0
    convergents.push((p, q))
    p0 = p1
    p1 = p
    q0 = q1
    q1 = q
  }
  convergents
}

///|
pub fn continued_fraction_reduce(cf : Array[Int]) -> (Int, Int) {
  if cf.length() == 0 {
    return (0, 1)
  }
  let mut num = 1
  let mut den = 0
  let mut i = cf.length() - 1
  while true {
    let a = cf[i]
    let next_num = a * num + den
    den = num
    num = next_num
    if i == 0 {
      break
    }
    i -= 1
  }
  (num, den)
}
