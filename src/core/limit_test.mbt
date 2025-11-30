///|
test "limit reciprocal directions" {
  let x = sym("x")
  let expr = div(int(1), sub(x, int(1)))
  inspect(limit(expr, "x", int(1)), content="Divergent")
  inspect(limit_left(expr, "x", int(1)), content="NegInf")
  inspect(limit_right(expr, "x", int(1)), content="PosInf")
}

///|
test "limit mirrored difference directions" {
  let x = sym("x")
  let expr = div(int(2), sub(int(3), x))
  inspect(limit_left(expr, "x", int(3)), content="PosInf")
  inspect(limit_right(expr, "x", int(3)), content="NegInf")
}

///|
test "classify zero over zero" {
  let expr = div(int(0), int(0))
  match classify_indeterminate(expr, "x", int(0)) {
    Some(form) => inspect(form, content="ZeroOverZero")
    None => abort("expected zero over zero")
  }
}

///|
test "classify infinity forms" {
  let expr_div = div(pos_infinity(), neg_infinity())
  match classify_indeterminate(expr_div, "x", int(0)) {
    Some(form) => inspect(form, content="InfinityOverInfinity")
    None => abort("expected infinity over infinity")
  }
  let expr_add = add(pos_infinity(), neg_infinity())
  match classify_indeterminate(expr_add, "x", int(0)) {
    Some(form) => inspect(form, content="InfinityMinusInfinity")
    None => abort("expected infinity minus infinity")
  }
}

///|
test "classify oscillatory sine" {
  let x = sym("x")
  let expr = sin(sub(x, int(1)))
  match classify_indeterminate(expr, "x", int(1)) {
    Some(form) => inspect(form, content="Oscillatory")
    None => abort("expected oscillatory behavior")
  }
}

///|
test "limit sin over identity via taylor" {
  let x = sym("x")
  let expr = div(sin(x), x)
  inspect(limit(expr, "x", int(0)), content="Value(1)")
}

///|
test "limit one minus cos over square" {
  let x = sym("x")
  let expr = div(sub(int(1), cos(x)), pow(x, int(2)))
  inspect(limit(expr, "x", int(0)), content="Value(1 / 2)")
}

///|
test "limit exp minus one over identity" {
  let x = sym("x")
  let expr = div(sub(exp(x), int(1)), x)
  inspect(limit(expr, "x", int(0)), content="Value(1)")
}

///|
test "limit log one plus over identity" {
  let x = sym("x")
  let expr = div(log(add(int(1), x)), x)
  inspect(limit(expr, "x", int(0)), content="Value(1)")
}
