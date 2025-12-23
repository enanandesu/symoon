///|
pub fn egyptian_fraction(
  n : Int,
  d? : Int = 1,
  algorithm? : String = "Greedy",
) -> Array[Int] {
  if algorithm != "Greedy" {
    return Array::new()
  }
  let mut denom = d
  if n <= 0 || denom <= 0 {
    return Array::new()
  }
  let mut num = n
  if denom < 0 {
    denom = -denom
    num = -num
  }
  if num <= 0 {
    return Array::new()
  }
  let result = Array::new()
  let mut a = num
  let mut b = denom
  while a != 0 {
    if a >= b {
      result.push(1)
      a = a - b
    } else {
      let k = (b + a - 1) / a
      result.push(k)
      a = a * k - b
      b = b * k
      let g = nt_gcd(a, b)
      if g > 1 {
        a = a / g
        b = b / g
      }
    }
  }
  result
}
