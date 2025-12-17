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
fn int_sqrt(n : Int) -> Int {
  if n <= 0 {
    return 0
  }
  let mut x = n
  let mut y = (x + 1) / 2
  while y < x {
    x = y
    y = (x + n / x) / 2
  }
  x
}

///|
fn is_perfect_square(n : Int) -> Bool {
  if n < 0 {
    return false
  }
  let r = int_sqrt(n)
  r * r == n
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
