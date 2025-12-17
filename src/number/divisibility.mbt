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
