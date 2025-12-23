///|
test "nt_gcd and nt_lcm handle common cases" {
  assert_eq(nt_gcd(54, 24), 6)
  assert_eq(nt_gcd(-54, 24), 6)
  assert_eq(nt_lcm(6, 8), 24)
  assert_eq(nt_lcm(0, 5), 0)
}

///|
test "gcd/lcm aliases match nt_ versions" {
  assert_eq(gcd(12, 18), 6)
  assert_eq(lcm(12, 18), 36)
  assert_eq(igcd(12, 18), 6)
  assert_eq(ilcm(12, 18), 36)
}

///|
test "nt_gcd_ex finds Bézout coefficients" {
  let (x, y, g) = nt_gcd_ex(12, 18)
  assert_eq((x, y, g), (-1, 1, 6))
  let (x2, y2, g2) = nt_gcd_ex(0, 5)
  assert_eq((x2, y2, g2), (0, 1, 5))
  let (x3, y3, g3) = nt_gcd_ex(-10, 15)
  assert_eq(-10 * x3 + 15 * y3, g3)
  assert_eq(g3, 5)
}

///|
test "gcdex alias matches nt_gcd_ex" {
  let (x, y, g) = gcdex(12, 18)
  assert_eq((x, y, g), (-1, 1, 6))
}

///|
test "mod_inverse and modular square roots" {
  assert_eq(mod_inverse(3, 11), 4)
  assert_eq(mod_inverse(2, 4), 0)
  let roots = sqrt_mod(4, 7)
  assert_eq(roots, [2, 5])
  let none = sqrt_mod(3, 7)
  assert_eq(none.length(), 0)
}

///|
test "quadratic_residues lists squares modulo n" {
  let residues = quadratic_residues(7)
  assert_eq(residues, [0, 1, 2, 4])
}

///|
test "totient mobius and prime factor counters" {
  assert_eq(totient(12), 4)
  assert_eq(mobius(12), 0)
  assert_eq(mobius(11), -1)
  assert_eq(primenu(12), 2)
  assert_eq(primeomega(12), 3)
}

///|
test "mobius and prime counters cover edge cases" {
  assert_eq(mobius(-30), 1)
  assert_eq(mobius(1), 1)
  assert_eq(mobius(64), 0)
  assert_eq(primenu(1), 0)
  assert_eq(primenu(360), 3)
  assert_eq(primeomega(360), 6)
  assert_eq(primeomega(0), 0)
}

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
test "binomial handles typical and edge cases" {
  assert_eq(binomial(10, 3), 120)
  assert_eq(binomial(5, 0), 1)
  assert_eq(binomial(5, 5), 1)
  assert_eq(binomial(5, 6), 0)
  assert_eq(binomial(-1, 2), 0)
}

///|
test "partition counts via npartitions" {
  assert_eq(npartitions(0), 1)
  assert_eq(npartitions(4), 5)
  assert_eq(npartitions(5), 7)
  assert_eq(npartitions(10), 42)
  assert_eq(npartitions(-3), 0)
}

///|
test "stirling numbers of both kinds" {
  assert_eq(stirling(5, 2, kind=2), 15)
  assert_eq(stirling(5, 2, kind=1), 50)
  assert_eq(stirling(3, 1, kind=2), 1)
  assert_eq(stirling(3, 1, kind=1), 2)
  assert_eq(stirling(4, 0, kind=2), 0)
  assert_eq(stirling(0, 0, kind=1), 1)
}

///|
test "sum_of_squares detects representability" {
  assert_eq(sum_of_squares(5), 1)
  assert_eq(sum_of_squares(3), 0)
  assert_eq(sum_of_squares(0), 1)
  assert_eq(sum_of_squares(-1), 0)
}

///|
test "set partitions from RGS" {
  let p = Partition::from_rgs([0, 1, 1, 0], [10, 20, 30, 40])
  let blocks = p.partition()
  assert_eq(blocks.length(), 2)
  assert_eq(blocks[0], [10, 40])
  assert_eq(blocks[1], [20, 30])
  assert_eq(p.rgs(), [0, 1, 1, 0])
  assert_eq(p.rank(), 2)
  assert_eq(p.sort_key(), "0,1,1,0")
  let invalid = Partition::from_rgs([0, 1], [1])
  assert_eq(invalid.partition().length(), 0)
}

///|
test "integer partition utilities" {
  let p = IntegerPartition::new([3, 1, 1, 0])
  let counts = p.as_dict()
  assert_eq(counts.get(3), Some(1))
  assert_eq(counts.get(1), Some(2))
  let ferrers = p.as_ferrers()
  assert_eq(ferrers, "###\n#\n#")
  let ferrers_star = p.as_ferrers(char="*")
  assert_eq(ferrers_star, "***\n*\n*")
  let conjugate = p.conjugate()
  assert_eq(conjugate.parts(), [3, 1, 1])
  let lex = IntegerPartition::new([3, 1])
  assert_eq(lex.next_lex().parts(), [2, 2])
  assert_eq(lex.prev_lex().parts(), [4])
  let last = IntegerPartition::new([1, 1, 1, 1])
  assert_eq(last.next_lex().parts(), [4])
  assert_eq(last.prev_lex().parts(), [2, 1, 1])
}

///|
test "random integer partitions are deterministic with seed" {
  let p = random_integer_partition(10, seed=123)
  assert_eq(p, [7, 3])
  let q = random_integer_partition(5)
  let mut total = 0
  for value in q {
    total += value
  }
  assert_eq(total, 5)
  let empty = random_integer_partition(0)
  assert_eq(empty.length(), 0)
}

///|
test "RGS helpers enumerate and rank" {
  let list3 = rgs_generalized(3)
  assert_eq(list3, [[0, 0, 0], [0, 0, 1], [0, 1, 0], [0, 1, 1], [0, 1, 2]])
  assert_eq(rgs_enum(3), 5)
  assert_eq(rgs_rank([0, 1, 0]), 2)
  assert_eq(rgs_rank([1]), -1)
  assert_eq(rgs_unrank(4, 3), [0, 1, 2])
  let none = rgs_unrank(10, 3)
  assert_eq(none.length(), 0)
}

///|
test "permutation basics and composition" {
  let p = Permutation::new([2, 0, 1])
  assert_eq(p.length(), 3)
  assert_eq(p.array_form(), [2, 0, 1])
  assert_eq(p.apply(1), 0)
  assert_eq(p.apply(-1), -1)
  let q = Permutation::new([1, 2, 0])
  let composed = p.compose(q)
  assert_eq(composed.array_form(), [0, 1, 2])
  let inv = p.inverse()
  assert_eq(inv.array_form(), [1, 2, 0])
  let bad = Permutation::new([0, 0])
  assert_eq(bad.length(), 0)
}

///|
test "permutation cycles parity and commutators" {
  let p = Permutation::new([2, 0, 1, 4, 3])
  let cycles = p.cycles()
  assert_eq(cycles, [[0, 2, 1], [3, 4]])
  assert_eq(p.cycle_structure(), [2, 3])
  assert_eq(p.cyclic_form(), "(0 2 1)(3 4)")
  assert_eq(p.parity(), -1)
  assert_eq(p.ascents(), [1, 2])
  assert_eq(p.descents(), [0, 3])
  let id = Permutation::identity(5)
  let comm = p.commutator(id)
  assert_eq(comm.array_form(), id.array_form())
  assert_eq(p.commutes_with(id), true)
}

///|
test "permutation rank and lex navigation" {
  let p = Permutation::new([1, 0, 2])
  assert_eq(p.rank_lex(), 2)
  let back = Permutation::unrank_lex(3, 2)
  assert_eq(back.array_form(), [1, 0, 2])
  assert_eq(p.next_lex().array_form(), [1, 2, 0])
  assert_eq(p.prev_lex().array_form(), [0, 2, 1])
}

///|
test "permutation group basic data and order" {
  let gen = Permutation::new([1, 0, 2])
  let group = PermutationGroup::new([gen])
  assert_eq(group.order(), 2)
  let base = group.base()
  assert_eq(base, [0, 1, 2])
  let orbits = group.basic_orbits()
  assert_eq(orbits[0], [0, 1])
  assert_eq(orbits[1], [1])
  assert_eq(orbits[2], [2])
  let stabilizers = group.basic_stabilizers()
  assert_eq(stabilizers.length(), 3)
  assert_eq(stabilizers[0].length(), 1)
  assert_eq(stabilizers[1].length(), 1)
  let transversals = group.basic_transversals()
  let t0 = transversals[0].get(0).unwrap()
  let t1 = transversals[0].get(1).unwrap()
  assert_eq(t0.apply(0), 0)
  assert_eq(t1.apply(0), 1)
  let invs = group.abelian_invariants()
  assert_eq(invs, [2])
}

///|
test "permutation group with 3-cycle" {
  let cycle = Permutation::new([1, 2, 0])
  let group = PermutationGroup::new([cycle])
  assert_eq(group.order(), 3)
  let orbits = group.basic_orbits()
  assert_eq(orbits[0], [0, 1, 2])
  let transversals = group.basic_transversals()
  let t0 = transversals[0].get(0).unwrap().array_form()
  let t1 = transversals[0].get(1).unwrap().array_form()
  let t2 = transversals[0].get(2).unwrap().array_form()
  assert_eq(t0, [0, 1, 2])
  assert_eq(t1, [1, 2, 0])
  assert_eq(t2, [2, 0, 1])
  let invs = group.abelian_invariants()
  assert_eq(invs, [3])
}

///|
test "polyhedron basic transforms" {
  let corners = [10, 20, 30, 40]
  let faces = [[0, 1, 2], [0, 2, 3]]
  let swap01 = Permutation::new([1, 0, 2, 3])
  let poly = Polyhedron::new(corners, faces~, pgroup=[swap01])
  assert_eq(poly.size(), 4)
  assert_eq(poly.vertices(), [10, 20, 30, 40])
  assert_eq(poly.corners(), [10, 20, 30, 40])
  assert_eq(poly.faces(), [[0, 1, 2], [0, 2, 3]])
  let edges = poly.edges()
  assert_eq(edges.length() >= 4, true)
  let rotated = poly.rotate_by_index(0)
  assert_eq(rotated.corners(), [20, 10, 30, 40])
  assert_eq(rotated.array_form(), [1, 0, 2, 3])
  assert_eq(rotated.cyclic_form(), "(0 1)(2)(3)")
  let reset = rotated.reset()
  assert_eq(reset.corners(), [10, 20, 30, 40])
  let by_perm = poly.rotate(Permutation::new([1, 2, 3, 0]))
  assert_eq(by_perm.corners(), [20, 30, 40, 10])
}

///|
test "prufer to_tree and to_prufer roundtrip" {
  let seq = [0, 0]
  let edges = to_tree(seq)
  let expected = sort_edges([(0, 1), (0, 2), (0, 3)])
  assert_eq(sort_edges(edges), expected)
  let back = to_prufer(edges, 4)
  assert_eq(back, seq)
}

///|
test "prufer next prev rank and unrank" {
  let p = Prufer::new([0, 0])
  assert_eq(p.size(), 4)
  assert_eq(p.nodes(), [0, 1, 2, 3])
  let n1 = p.next()
  assert_eq(n1.prufer_repr(), [0, 1])
  let p_prev = p.prev()
  assert_eq(p_prev.prufer_repr(), [3, 3])
  assert_eq(p.prufer_rank(), 0)
  let r = Prufer::unrank(6, 4)
  assert_eq(r.prufer_repr(), [1, 2])
  let rank_back = r.rank()
  assert_eq(rank_back, 6)
}

///|
test "prufer edges and tree representation" {
  let p = Prufer::new([3, 3, 3])
  let edges = p.edges()
  let sorted = sort_edges(edges)
  let expected = sort_edges([(0, 3), (1, 3), (2, 3), (3, 4)])
  assert_eq(sorted, expected)
  let tree_repr = p.tree_repr()
  assert_eq(sort_edges(tree_repr), expected)
}

///|
test "gray code basics and navigation" {
  let g = GrayCode::new(3)
  assert_eq(g.current(), "000")
  let g1 = g.next()
  assert_eq(g1.current(), "001")
  let g2 = g1.next(delta=2)
  assert_eq(g2.current(), "010")
  let back = g2.skip(delta=-3)
  assert_eq(back.current(), "000")
}

///|
test "gray code rank and generate" {
  let codes = generate_gray(2)
  assert_eq(codes, ["00", "01", "11", "10"])
  let g = GrayCode::new(2, rank=3)
  assert_eq(g.rank(), 3)
  assert_eq(g.current(), "10")
  let u = GrayCode::unrank(2, 1)
  assert_eq(u.current(), "01")
}

///|
test "gray code helpers and subsets" {
  let rand = random_bitstring(4, seed=5)
  assert_eq(rand.length(), 4)
  let gray = bin_to_gray("0101")
  assert_eq(gray, "0111")
  let bin = gray_to_bin(gray)
  assert_eq(bin, "0101")
  let subset = get_subset_from_bitstring([1, 2, 3, 4], "1010")
  assert_eq(subset, [1, 3])
  let subsets = graycode_subsets([10, 20])
  assert_eq(subsets, [[], [20], [10, 20], [10]])
}

///|
test "subset bitlist and rank conversions" {
  let sup = [10, 20, 30]
  let sub = [10, 30]
  let bits = bitlist_from_subset(sub, sup)
  assert_eq(bits, "101")
  let back = subset_from_bitlist(sup, bits)
  assert_eq(back, [10, 30])
  assert_eq(rank_binary(sub, sup), 5)
  assert_eq(unrank_binary(5, sup), [10, 30])
  assert_eq(rank_gray(sub, sup), 7)
  assert_eq(unrank_gray(7, sup), [10, 30])
  assert_eq(rank_lexicographic(sub, sup), 5)
  assert_eq(subset_indices(sub, sup), [0, 2])
}

///|
test "subset iteration and navigation" {
  let sup = [1, 2]
  let all_bin = iterate_binary(sup)
  assert_eq(all_bin, [[], [2], [1], [1, 2]])
  let all_gray = iterate_graycode(sup)
  assert_eq(all_gray, [[], [2], [1, 2], [1]])
  let next = next_binary([1], sup)
  assert_eq(next, [1, 2])
  let prev = prev_binary([1], sup)
  assert_eq(prev, [2])
  let ng = next_gray([1], sup)
  assert_eq(ng, [])
  let pg = prev_gray([1], sup)
  assert_eq(pg, [1, 2])
}

///|
test "ksubsets generates combinations" {
  let result = ksubsets([1, 2, 3], 2)
  assert_eq(result, [[1, 2], [1, 3], [2, 3]])
  let empty = ksubsets([1, 2], 3)
  assert_eq(empty.length(), 0)
}

///|
test "factor helpers primefactors and perfect_power" {
  assert_eq(primefactors(84), [2, 3, 7])
  assert_eq(primefactors(-45), [3, 5])
  assert_eq(perfect_power(27), true)
  assert_eq(perfect_power(16), true)
  assert_eq(perfect_power(18), false)
  assert_eq(trailing(40), 3)
  let factors = pollard_rho(84)
  assert_eq(factors, [(2, 2), (3, 1), (7, 1)])
  let factors2 = pollard_pm1(45)
  assert_eq(factors2, [(3, 2), (5, 1)])
}

///|
test "named groups symmetric alternating cyclic dihedral" {
  let s3 = symmetric_group(3)
  assert_eq(s3.order(), 6)
  let a3 = alternating_group(3)
  assert_eq(a3.order(), 3)
  let c4 = cyclic_group(4)
  assert_eq(c4.order(), 4)
  let d4 = dihedral_group(4)
  assert_eq(d4.order(), 8)
  let base = d4.base()
  assert_eq(base, [0, 1, 2, 3])
}

///|
test "prime generation helpers" {
  assert_eq(prime(5), 11)
  assert_eq(primepi(10), 4)
  let primes = primerange(10, 20)
  assert_eq(primes, [11, 13, 17, 19])
  let r = randprime(20, 30, seed=5)
  assert_eq(nt_is_prime(r), true)
  assert_eq(primorial(5), 2310)
  assert_eq(primorial(5, nth=false), 30)
}

///|
test "composite counting and nth composite" {
  assert_eq(compositepi(10), 4)
  assert_eq(composite(1), 4)
  assert_eq(composite(5), 10)
}

///|
test "sieve basic usage and cycle length" {
  let s = Sieve::new().extend(20)
  let plist = s.primerange(2, 15)
  assert_eq(plist, [2, 3, 5, 7, 11, 13])
  fn f(x : Int) -> Int {
    (x * x + 1) % 10
  }

  let len = cycle_length(f, 2)
  assert_eq(len > 0, true)
}

///|
test "linear diophantine solver returns parametric form" {
  let (x0, y0, sx, sy) = diophantine_linear(2, 3, 10)
  assert_eq(2 * x0 + 3 * y0, 10)
  let x = x0 + sx
  let y = y0 + sy
  assert_eq(2 * x + 3 * y, 10)
}

///|
test "pell solutions generate first terms for d=2" {
  let sols = pell_solutions(2, count=3)
  assert_eq(sols, [(3, 2), (17, 12), (99, 70)])
  for pair in sols {
    let (x, y) = pair
    assert_eq(x * x - 2 * y * y, 1)
  }
  let none = pell_solutions(4, count=3)
  assert_eq(none.length(), 0)
}

///|
test "pythagorean triples generator yields primitive triples" {
  let triples = pythagorean_triples(2)
  assert_eq(triples.length(), 2)
  assert_eq(triples[0], (3, 4, 5))
  assert_eq(triples[1], (5, 12, 13))
}

///|
test "quadratic symbols and residue checks" {
  assert_eq(legendre_symbol(2, 7), 1)
  assert_eq(jacobi_symbol(15, 23), -1)
  assert_eq(is_quad_residue(2, 7), true)
  assert_eq(is_quad_residue(3, 7), false)
}

///|
test "quadratic symbol edge cases and residue listing" {
  assert_eq(legendre_symbol(0, 7), 0)
  assert_eq(legendre_symbol(2, 8), 0)
  assert_eq(jacobi_symbol(2, 9), 1)
  assert_eq(jacobi_symbol(5, 21), 1)
  let residues = quadratic_residues(11)
  assert_eq(residues, [0, 1, 3, 4, 5, 9])
  assert_eq(is_quad_residue(3, 11), true)
  assert_eq(is_quad_residue(2, 11), false)
}

///|
test "kronecker symbol and multiplicative order" {
  assert_eq(kronecker_symbol(3, 8), -1)
  assert_eq(kronecker_symbol(5, 8), -1)
  assert_eq(kronecker_symbol(5, -7), -1)
  assert_eq(n_order(3, 7), 6)
  assert_eq(n_order(2, 9), 6)
  assert_eq(n_order(2, 10), 0)
}

///|
test "solve_congruence combines pairwise congruences" {
  let (x, modulus) = solve_congruence([(2, 3), (3, 5), (2, 7)])
  assert_eq((x, modulus), (23, 105))
  let impossible = solve_congruence([(1, 2), (0, 4)])
  assert_eq(impossible, (0, 0))
}

///|
test "solve_congruence normalizes residues and negatives" {
  let (x1, m1) = solve_congruence([(-1, 5), (1, 6)])
  assert_eq((x1, m1), (19, 30))
  let (x2, m2) = solve_congruence([(4, 5), (4, 10)])
  assert_eq((x2, m2), (4, 10))
}

///|
test "nt_is_prime checks small and composite numbers" {
  assert_eq(nt_is_prime(1), false)
  assert_eq(nt_is_prime(2), true)
  assert_eq(nt_is_prime(17), true)
  assert_eq(nt_is_prime(21), false)
}

///|
test "nt_is_divisible_by covers zero and negatives" {
  assert_eq(nt_is_divisible_by(10, 2), true)
  assert_eq(nt_is_divisible_by(10, 3), false)
  assert_eq(nt_is_divisible_by(0, 5), true)
  assert_eq(nt_is_divisible_by(5, 0), false)
  assert_eq(nt_is_divisible_by(-12, 3), true)
  assert_eq(nt_is_divisible_by(12, -3), true)
}

///|
test "nt_is_divisible_by_all_and_any handle collections" {
  assert_eq(nt_is_divisible_by_all(60, [2, 3, 5]), true)
  assert_eq(nt_is_divisible_by_all(12, [2, 5]), false)
  assert_eq(nt_is_divisible_by_all(10, []), true)
  assert_eq(nt_is_divisible_by_any(14, [3, 5, 7]), true)
  assert_eq(nt_is_divisible_by_any(25, [2, 4]), false)
  assert_eq(nt_is_divisible_by_any(10, []), false)
}

///|
test "nt_primes_up_to lists primes within limit" {
  let empty = nt_primes_up_to(1)
  assert_eq(empty.length(), 0)
  let primes = nt_primes_up_to(20)
  assert_eq(primes, [2, 3, 5, 7, 11, 13, 17, 19])
}

///|
test "nt_nth_prime and nt_prime_pi" {
  assert_eq(nt_nth_prime(1), 2)
  assert_eq(nt_nth_prime(10), 29)
  assert_eq(nt_nth_prime(0), 0)
  assert_eq(nt_prime(10), 29)
  assert_eq(nt_prime_pi(1), 0)
  assert_eq(nt_prime_pi(2), 1)
  assert_eq(nt_prime_pi(100), 25)
}

///|
test "prime helpers aliases" {
  assert_eq(isprime(17), true)
  assert_eq(isprime(1), false)
  assert_eq(prime(6), 13)
  assert_eq(prime(0), 0)
  assert_eq(primepi(10), 4)
  assert_eq(primepi(100), 25)
  let range = primerange(10, 20)
  assert_eq(range, [11, 13, 17, 19])
  let small = primerange(-5, 5)
  assert_eq(small, [2, 3])
}

///|
test "nt_next_prev_prime locate neighbors" {
  assert_eq(nt_next_prime(50), 53)
  assert_eq(nt_prev_prime(50), 47)
  assert_eq(nt_next_prime(2), 3)
  assert_eq(nt_prev_prime(3), 2)
  assert_eq(nt_prev_prime(2), 0)
}

///|
test "nextprime and prevprime aliases mirror nt versions" {
  assert_eq(nextprime(50), 53)
  assert_eq(prevprime(50), 47)
  assert_eq(nextprime(-10), 2)
  assert_eq(prevprime(2), 0)
}

///|
test "nt_prime_range builds half-open ranges" {
  let range = nt_prime_range(10, 30)
  assert_eq(range, [11, 13, 17, 19, 23, 29])
  let small = nt_prime_range(-5, 5)
  assert_eq(small, [2, 3])
  let empty = nt_prime_range(20, 20)
  assert_eq(empty.length(), 0)
}

///|
test "nt_rand_prime picks deterministic prime inside range" {
  let default_pick = nt_rand_prime(100, 200)
  assert_eq(default_pick, 131)
  assert_eq(nt_is_prime(default_pick), true)
  assert_eq(default_pick >= 100 && default_pick < 200, true)
  let seeded = nt_rand_prime(100, 200, seed=7)
  assert_eq(seeded, 137)
  assert_eq(nt_rand_prime(14, 16), 0)
}

///|
test "nt_first_n_primes returns the requested count" {
  let none = nt_first_n_primes(0)
  assert_eq(none.length(), 0)
  let first_five = nt_first_n_primes(5)
  assert_eq(first_five, [2, 3, 5, 7, 11])
}

///|
test "nt_prime_factors factorizes integers" {
  let factors = nt_prime_factors(84)
  assert_eq(factors, [(2, 2), (3, 1), (7, 1)])
  let negative = nt_prime_factors(-45)
  assert_eq(negative, [(3, 2), (5, 1)])
  let unity = nt_prime_factors(1)
  assert_eq(unity.length(), 0)
  let zero = nt_prime_factors(0)
  assert_eq(zero.length(), 0)
}

///|
test "nt_prime_factor_list expands factors with multiplicity" {
  let list = nt_prime_factor_list(360)
  assert_eq(list, [2, 2, 2, 3, 3, 5])
  let negative = nt_prime_factor_list(-45)
  assert_eq(negative, [3, 3, 5])
  let prime_number = nt_prime_factor_list(13)
  assert_eq(prime_number, [13])
  let unity = nt_prime_factor_list(1)
  assert_eq(unity.length(), 0)
}

///|
test "nt_factorint and nt_multiplicity match expectations" {
  let f100 = nt_factorint(100)
  assert_eq(f100.get(2), Some(2))
  assert_eq(f100.get(5), Some(2))
  assert_eq(f100.get(7), None)
  let mut entries = 0
  for _ in f100 {
    entries += 1
  }
  assert_eq(entries, 2)
  let f123456 = nt_factorint(123456)
  assert_eq(f123456.get(2), Some(6))
  assert_eq(f123456.get(3), Some(1))
  assert_eq(f123456.get(643), Some(1))
  let mut entries2 = 0
  for _ in f123456 {
    entries2 += 1
  }
  assert_eq(entries2, 3)
  assert_eq(nt_multiplicity(2, 100), 2)
  assert_eq(nt_multiplicity(5, 100), 2)
  assert_eq(nt_multiplicity(7, 100), 0)
  assert_eq(nt_multiplicity(2, -40), 3)
}

///|
test "factorint and multiplicity aliases mirror nt_ versions" {
  let f100 = factorint(100)
  assert_eq(f100.get(2), Some(2))
  assert_eq(f100.get(5), Some(2))
  let f123456 = factorint(123456)
  assert_eq(f123456.get(2), Some(6))
  assert_eq(f123456.get(3), Some(1))
  assert_eq(f123456.get(643), Some(1))
  assert_eq(multiplicity(2, 100), 2)
  assert_eq(multiplicity(5, 100), 2)
}

///|
test "nt_divisors count and sigma" {
  let divisors = nt_divisors(12)
  assert_eq(divisors, [1, 2, 3, 4, 6, 12])
  assert_eq(nt_divisor_count(12), 6)
  assert_eq(nt_divisors(-10), [1, 2, 5, 10])
  assert_eq(nt_divisor_count(1), 1)
  assert_eq(nt_divisor_count(0), 0)
  assert_eq(nt_divisor_sigma(12), 28)
  assert_eq(nt_divisor_sigma(12, power=2), 210)
  assert_eq(nt_divisor_sigma(1), 1)
  assert_eq(nt_divisor_sigma(0), 0)
}

///|
test "divisors, divisor_count, divisor_sigma aliases mirror nt_ versions" {
  assert_eq(divisors(12), [1, 2, 3, 4, 6, 12])
  assert_eq(divisor_count(12), 6)
  assert_eq(divisor_sigma(12), 28)
  assert_eq(divisor_sigma(12, power=2), 210)
}

///|
test "nt_totient matches known values" {
  assert_eq(nt_totient(1), 1)
  assert_eq(nt_totient(9), 6)
  assert_eq(nt_totient(36), 12)
}

///|
test "carmichael function computes lambda" {
  assert_eq(carmichael(1), 1)
  assert_eq(carmichael(2), 1)
  assert_eq(carmichael(4), 2)
  assert_eq(carmichael(8), 2)
  assert_eq(carmichael(9), 6)
  assert_eq(carmichael(15), 4)
  assert_eq(carmichael(21), 6)
  assert_eq(carmichael(0), 0)
}
