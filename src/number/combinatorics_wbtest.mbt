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
test "multinomial coefficients for small cases" {
  let m2 = multinomial_coefficients(2, 3)
  assert_eq(m2, [([0, 3], 1), ([1, 2], 3), ([2, 1], 3), ([3, 0], 1)])
  let m3 = multinomial_coefficients(3, 2)
  assert_eq(m3, [
    ([0, 0, 2], 1),
    ([0, 1, 1], 2),
    ([0, 2, 0], 1),
    ([1, 0, 1], 2),
    ([1, 1, 0], 2),
    ([2, 0, 0], 1),
  ])
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
test "cycle length returns a positive value" {
  fn f(x : Int) -> Int {
    (x * x + 1) % 10
  }

  let len = cycle_length(f, 2)
  assert_eq(len > 0, true)
}
