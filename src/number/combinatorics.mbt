///|
pub fn binomial(n : Int, k : Int) -> Int {
  if n < 0 || k < 0 || k > n {
    return 0
  }
  if k == 0 || k == n {
    return 1
  }
  let mut kk = k
  if kk > n - kk {
    kk = n - kk
  }
  let mut result = 1
  let mut i = 1
  while i <= kk {
    result = result * (n - kk + i) / i
    i += 1
  }
  result
}

///|
pub fn npartitions(n : Int) -> Int {
  if n < 0 {
    return 0
  }
  let target = n
  let dp = Array::new()
  let mut i = 0
  while i <= target {
    dp.push(0)
    i += 1
  }
  dp[0] = 1
  let mut part = 1
  while part <= target {
    let mut j = part
    while j <= target {
      dp[j] = dp[j] + dp[j - part]
      j += 1
    }
    part += 1
  }
  dp[target]
}

///|
fn stirling_first_kind_unsigned(n : Int, k : Int) -> Int {
  if n < 0 || k < 0 || k > n {
    return 0
  }
  if n == 0 && k == 0 {
    return 1
  }
  if k == 0 {
    return 0
  }
  if k == n {
    return 1
  }
  (n - 1) * stirling_first_kind_unsigned(n - 1, k) +
  stirling_first_kind_unsigned(n - 1, k - 1)
}

///|
fn stirling_second_kind(n : Int, k : Int) -> Int {
  if n < 0 || k < 0 || k > n {
    return 0
  }
  if n == 0 && k == 0 {
    return 1
  }
  if k == 0 {
    return 0
  }
  if k == n {
    return 1
  }
  k * stirling_second_kind(n - 1, k) + stirling_second_kind(n - 1, k - 1)
}

///|
pub fn stirling(n : Int, k : Int, kind? : Int = 2) -> Int {
  if kind == 1 {
    stirling_first_kind_unsigned(n, k)
  } else if kind == 2 {
    stirling_second_kind(n, k)
  } else {
    0
  }
}
