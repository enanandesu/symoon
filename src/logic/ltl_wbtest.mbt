///|
test "ltl basic temporal constructors" {
  let p = ltl_symbol("p")
  let q = ltl_symbol("q")
  let always_p = ltl_always(p.copy())
  let eventually_p = ltl_eventually(p.copy())
  let until_expr = ltl_until(p.copy(), q.copy())
  let next_p = ltl_next(p.copy())
  let release_expr = ltl_release(p.copy(), q.copy())
  match always_p {
    Always(inner) => assert_eq(inner, p)
    _ => abort("expected Always")
  }
  match eventually_p {
    Eventually(inner) => assert_eq(inner, p)
    _ => abort("expected Eventually")
  }
  match until_expr {
    Until(lhs, rhs) => {
      assert_eq(lhs, p)
      assert_eq(rhs, q)
    }
    _ => abort("expected Until")
  }
  match next_p {
    Next(inner) => assert_eq(inner, p)
    _ => abort("expected Next")
  }
  match release_expr {
    Release(lhs, rhs) => {
      assert_eq(lhs, p)
      assert_eq(rhs, q)
    }
    _ => abort("expected Release")
  }
}

///|
test "ltl_eval handles Always and Eventually over traces" {
  let p = ltl_symbol("p")
  let trace : Array[Array[(String, Bool)]] = [
    [("p", true)],
    [("p", true)],
    [("p", true)],
  ]
  assert_eq(ltl_eval(ltl_always(p.copy()), trace), Some(true))
  let trace2 : Array[Array[(String, Bool)]] = [[("p", false)], [("p", true)]]
  assert_eq(ltl_eval(ltl_eventually(p.copy()), trace2), Some(true))
}

///|
test "ltl_eval handles Until and Release" {
  let p = ltl_symbol("p")
  let q = ltl_symbol("q")
  let trace : Array[Array[(String, Bool)]] = [
    [("p", true), ("q", false)],
    [("p", true), ("q", true)],
  ]
  assert_eq(ltl_eval(ltl_until(p.copy(), q.copy()), trace), Some(true))
  let trace_release : Array[Array[(String, Bool)]] = [
    [("p", false), ("q", true)],
    [("p", false), ("q", true)],
  ]
  assert_eq(
    ltl_eval(ltl_release(p.copy(), q.copy()), trace_release),
    Some(true),
  )
}

///|
test "ltl_eval handles Next and absorption with missing future" {
  let p = ltl_symbol("p")
  let trace : Array[Array[(String, Bool)]] = [[("p", true)]]
  assert_eq(ltl_eval(ltl_next(p.copy()), trace), None)
  let trace2 : Array[Array[(String, Bool)]] = [[("p", false)], [("p", true)]]
  assert_eq(ltl_eval(ltl_next(p.copy()), trace2), Some(true))
}
