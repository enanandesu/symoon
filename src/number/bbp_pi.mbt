///|
fn hex_digit(value : Int) -> String {
  let digits = [
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f",
  ]
  if value < 0 || value >= digits.length() {
    "0"
  } else {
    digits[value]
  }
}

///|
pub fn pi_hex_digits(n : Int, prec? : Int = 14) -> String {
  let count = prec
  if n < 0 || count < 0 {
    return ""
  }
  if count == 0 {
    return ""
  }
  let total = n + count
  if total <= 0 {
    return ""
  }
  let pi = 4.0 * @math.atan(1.0)
  let int_part = pi.to_int()
  let digits = Array::new()
  digits.push(int_part)
  let mut frac = pi - int_part.to_double()
  let mut i = 1
  while i < total {
    frac = frac * 16.0
    let digit = frac.to_int()
    digits.push(digit)
    frac = frac - digit.to_double()
    i += 1
  }
  let mut result = ""
  let mut idx = n
  while idx < total {
    result = result + hex_digit(digits[idx])
    idx += 1
  }
  result
}
