///|
test "fibonacci and lucas sequences" {
  assert_eq(fibonacci(0), 0)
  assert_eq(fibonacci(1), 1)
  assert_eq(fibonacci(10), 55)
  assert_eq(lucas(0), 2)
  assert_eq(lucas(1), 1)
  assert_eq(lucas(10), 123)
  assert_eq(fibonacci(-1), 0)
  assert_eq(lucas(-1), 0)
}

///|
test "fibonacci and lucas larger values" {
  assert_eq(fibonacci(20), 6765)
  assert_eq(lucas(20), 15127)
}
