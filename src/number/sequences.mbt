///|
pub fn fibonacci(n : Int) -> Int {
  if n < 0 {
    return 0
  }
  if n == 0 {
    return 0
  }
  if n == 1 {
    return 1
  }
  let mut a = 0
  let mut b = 1
  let mut i = 1
  while i < n {
    let next = a + b
    a = b
    b = next
    i += 1
  }
  b
}

///|
pub fn lucas(n : Int) -> Int {
  if n < 0 {
    return 0
  }
  if n == 0 {
    return 2
  }
  if n == 1 {
    return 1
  }
  let mut a = 2
  let mut b = 1
  let mut i = 1
  while i < n {
    let next = a + b
    a = b
    b = next
    i += 1
  }
  b
}
