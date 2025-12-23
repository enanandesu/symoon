///|
pub fn digits(n : Int, b? : Int = 10, digits? : Int = 0) -> Array[Int] {
  let base = b
  if base <= 1 {
    return Array::new()
  }
  let mut value = n
  if value < 0 {
    value = -value
  }
  let out = Array::new()
  if value == 0 {
    out.push(0)
  } else {
    while value > 0 {
      out.push(value % base)
      value = value / base
    }
    let mut i = 0
    let mut j = out.length() - 1
    while i < j {
      let tmp = out[i]
      out[i] = out[j]
      out[j] = tmp
      i += 1
      j -= 1
    }
  }
  let target_len = digits
  if target_len > 0 && target_len > out.length() {
    let padded = Array::new()
    let mut pad = 0
    while pad < target_len - out.length() {
      padded.push(0)
      pad += 1
    }
    for d in out {
      padded.push(d)
    }
    padded
  } else {
    out
  }
}

///|
pub fn count_digits(n : Int, base? : Int = 10) -> Map[Int, Int] {
  let counts : Map[Int, Int] = {}
  let list = digits(n, b=base)
  for d in list {
    match counts.get(d) {
      Some(value) => counts.set(d, value + 1)
      None => counts.set(d, 1)
    }
  }
  counts
}
