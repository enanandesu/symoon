///|
pub fn diophantine_linear(a : Int, b : Int, c : Int) -> (Int, Int, Int, Int) {
  if a == 0 && b == 0 {
    return if c == 0 { (0, 0, 0, 0) } else { (0, 0, 0, 0) }
  }
  let g = nt_gcd(a, b)
  if c % g != 0 {
    return (0, 0, 0, 0)
  }
  let (s, t, _) = nt_gcd_ex(a, b)
  let scale = c / g
  let x0 = s * scale
  let y0 = t * scale
  let step_x = b / g
  let step_y = -a / g
  (x0, y0, step_x, step_y)
}

///|
pub fn pell_solutions(d : Int, count? : Int = 5) -> Array[(Int, Int)] {
  let solutions = Array::new()
  if count <= 0 || d <= 0 || is_perfect_square(d) {
    return solutions
  }
  let mut y = 1
  let mut x1 = 0
  let mut y1 = 0
  let mut found = false
  while y <= 10000 {
    let candidate = 1 + d * y * y
    if is_perfect_square(candidate) {
      x1 = int_sqrt(candidate)
      y1 = y
      found = true
      break
    }
    y += 1
  }
  if !found {
    return solutions
  }
  let mut x = x1
  let mut yy = y1
  let mut i = 0
  while i < count {
    solutions.push((x, yy))
    let next_x = x1 * x + d * y1 * yy
    let next_y = x1 * yy + y1 * x
    x = next_x
    yy = next_y
    i += 1
  }
  solutions
}

///|
pub fn pythagorean_triples(count : Int) -> Array[(Int, Int, Int)] {
  let triples = Array::new()
  if count <= 0 {
    return triples
  }
  let mut m = 2
  while triples.length() < count {
    let mut n = 1
    while n < m {
      if (m - n) % 2 == 1 && nt_gcd(m, n) == 1 {
        let a = m * m - n * n
        let b = 2 * m * n
        let c = m * m + n * n
        let mut triple = (a, b, c)
        if triple.0 > triple.1 {
          triple = (triple.1, triple.0, triple.2)
        }
        triples.push(triple)
        if triples.length() >= count {
          return triples
        }
      }
      n += 1
    }
    m += 1
  }
  triples
}
