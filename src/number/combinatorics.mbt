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
pub fn multinomial_coefficients(m : Int, n : Int) -> Array[(Array[Int], Int)] {
  let results = Array::new()
  if m <= 0 || n < 0 {
    return results
  }
  fn dfs(
    index : Int,
    slots : Int,
    remaining : Int,
    current : Array[Int],
    coeff : Int,
    results : Array[(Array[Int], Int)],
  ) -> Unit {
    if index == slots - 1 {
      let full = Array::new()
      for value in current {
        full.push(value)
      }
      full.push(remaining)
      results.push((full, coeff))
      return ()
    }
    let mut k = 0
    while k <= remaining {
      let next = Array::new()
      for value in current {
        next.push(value)
      }
      next.push(k)
      let coeff_next = coeff * binomial(remaining, k)
      dfs(index + 1, slots, remaining - k, next, coeff_next, results)
      k += 1
    }
  }

  dfs(0, m, n, Array::new(), 1, results)
  results
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

///|
pub struct Partition {
  blocks : Array[Array[Int]]
  rgs : Array[Int]
}

///|
pub fn Partition::rgs(self : Partition) -> Array[Int] {
  self.rgs
}

///|
pub fn Partition::partition(self : Partition) -> Array[Array[Int]] {
  self.blocks
}

///|
pub fn Partition::rank(self : Partition) -> Int {
  self.blocks.length()
}

///|
pub fn Partition::sort_key(self : Partition) -> String {
  let mut key = ""
  let len = self.rgs.length()
  let mut i = 0
  while i < len {
    if i > 0 {
      key = key + ","
    }
    key = key + self.rgs[i].to_string()
    i += 1
  }
  key
}

///|
pub fn Partition::from_rgs(
  rgs : Array[Int],
  elements : Array[Int],
) -> Partition {
  let len = rgs.length()
  if len != elements.length() || len == 0 {
    return Partition::{ blocks: Array::new(), rgs: Array::new() }
  }
  let mut max_block = 0
  let mut i = 0
  while i < len {
    if rgs[i] < 0 {
      return Partition::{ blocks: Array::new(), rgs: Array::new() }
    }
    if rgs[i] > max_block {
      max_block = rgs[i]
    }
    i += 1
  }
  let blocks = Array::new()
  let mut b = 0
  while b <= max_block {
    blocks.push(Array::new())
    b += 1
  }
  i = 0
  while i < len {
    let block_index = rgs[i]
    blocks[block_index].push(elements[i])
    i += 1
  }
  Partition::{ blocks, rgs }
}

///|
pub struct IntegerPartition {
  parts : Array[Int]
}

///|
pub fn IntegerPartition::new(parts : Array[Int]) -> IntegerPartition {
  IntegerPartition::{ parts: normalize_parts(parts) }
}

///|
pub fn IntegerPartition::parts(self : IntegerPartition) -> Array[Int] {
  self.parts
}

///|
pub fn IntegerPartition::as_dict(self : IntegerPartition) -> Map[Int, Int] {
  let counts : Map[Int, Int] = {}
  for value in self.parts {
    match counts.get(value) {
      Some(existing) => counts.set(value, existing + 1)
      None => counts.set(value, 1)
    }
  }
  counts
}

///|
pub fn IntegerPartition::as_ferrers(
  self : IntegerPartition,
  char? : String = "#",
) -> String {
  let lines = Array::new()
  for part in self.parts {
    let mut line = ""
    let mut i = 0
    while i < part {
      line = line + char
      i += 1
    }
    lines.push(line)
  }
  let mut result = ""
  let total = lines.length()
  let mut idx = 0
  while idx < total {
    result = result + lines[idx]
    if idx + 1 < total {
      result = result + "\n"
    }
    idx += 1
  }
  result
}

///|
pub fn IntegerPartition::conjugate(self : IntegerPartition) -> IntegerPartition {
  let parts = self.parts
  let mut max_part = 0
  for value in parts {
    if value > max_part {
      max_part = value
    }
  }
  let conj = Array::new()
  let mut i = 1
  while i <= max_part {
    let mut count = 0
    for value in parts {
      if value >= i {
        count += 1
      }
    }
    if count > 0 {
      conj.push(count)
    }
    i += 1
  }
  IntegerPartition::{ parts: conj }
}

///|
pub fn IntegerPartition::next_lex(self : IntegerPartition) -> IntegerPartition {
  let n = sum_parts(self.parts)
  let partitions = generate_partitions_lex(n)
  let idx = find_partition_index(partitions, self.parts)
  if idx < 0 {
    return self
  }
  let len = partitions.length()
  let next_idx = if len == 0 { 0 } else { (idx + 1) % len }
  IntegerPartition::new(partitions[next_idx])
}

///|
pub fn IntegerPartition::prev_lex(self : IntegerPartition) -> IntegerPartition {
  let n = sum_parts(self.parts)
  let partitions = generate_partitions_lex(n)
  let idx = find_partition_index(partitions, self.parts)
  if idx < 0 {
    return self
  }
  let len = partitions.length()
  let prev_idx = if len == 0 { 0 } else { (idx + len - 1) % len }
  IntegerPartition::new(partitions[prev_idx])
}

///|
fn normalize_parts(parts : Array[Int]) -> Array[Int] {
  let filtered = Array::new()
  for value in parts {
    if value > 0 {
      filtered.push(value)
    }
  }
  let len = filtered.length()
  let mut i = 0
  while i < len {
    let mut max_index = i
    let mut j = i + 1
    while j < len {
      if filtered[j] > filtered[max_index] {
        max_index = j
      }
      j += 1
    }
    if max_index != i {
      let temp = filtered[i]
      filtered[i] = filtered[max_index]
      filtered[max_index] = temp
    }
    i += 1
  }
  filtered
}

///|
fn sum_parts(parts : Array[Int]) -> Int {
  let mut total = 0
  for value in parts {
    total += value
  }
  total
}

///|
fn generate_partitions_lex(n : Int) -> Array[Array[Int]] {
  let result = Array::new()
  let prefix = Array::new()
  gen_partitions(n, n, prefix, result)
}

///|
fn gen_partitions(
  remaining : Int,
  max_part : Int,
  prefix : Array[Int],
  acc : Array[Array[Int]],
) -> Array[Array[Int]] {
  if remaining == 0 {
    let base = acc
    base.push(prefix)
    return base
  }
  let mut result = acc
  let mut part = if remaining < max_part { remaining } else { max_part }
  while part >= 1 {
    let next_prefix = prefix.copy()
    next_prefix.push(part)
    result = gen_partitions(remaining - part, part, next_prefix, result)
    part -= 1
  }
  result
}

///|
fn find_partition_index(pool : Array[Array[Int]], target : Array[Int]) -> Int {
  let len = pool.length()
  let mut i = 0
  while i < len {
    if partitions_equal(pool[i], target) {
      return i
    }
    i += 1
  }
  -1
}

///|
fn partitions_equal(a : Array[Int], b : Array[Int]) -> Bool {
  if a.length() != b.length() {
    return false
  }
  let len = a.length()
  let mut i = 0
  while i < len {
    if a[i] != b[i] {
      return false
    }
    i += 1
  }
  true
}

///|
pub struct Permutation {
  mapping : Array[Int]
}

///|
pub fn Permutation::new(mapping : Array[Int]) -> Permutation {
  if is_valid_permutation(mapping) {
    Permutation::{ mapping, }
  } else {
    Permutation::{ mapping: Array::new() }
  }
}

///|
pub fn Permutation::identity(size : Int) -> Permutation {
  if size <= 0 {
    return Permutation::{ mapping: Array::new() }
  }
  let mapping = Array::new()
  let mut i = 0
  while i < size {
    mapping.push(i)
    i += 1
  }
  Permutation::{ mapping, }
}

///|
pub fn Permutation::length(self : Permutation) -> Int {
  self.mapping.length()
}

///|
pub fn Permutation::array_form(self : Permutation) -> Array[Int] {
  self.mapping
}

///|
pub fn Permutation::apply(self : Permutation, i : Int) -> Int {
  let n = self.mapping.length()
  if i < 0 || i >= n {
    -1
  } else {
    self.mapping[i]
  }
}

///|
pub fn Permutation::compose(
  self : Permutation,
  other : Permutation,
) -> Permutation {
  let n = self.mapping.length()
  if n == 0 || other.mapping.length() != n {
    return Permutation::{ mapping: Array::new() }
  }
  let mapping = Array::new()
  let mut i = 0
  while i < n {
    let value = self.apply(other.apply(i))
    mapping.push(value)
    i += 1
  }
  Permutation::{ mapping, }
}

///|
pub fn Permutation::inverse(self : Permutation) -> Permutation {
  let n = self.mapping.length()
  let inverse = Array::new()
  let mut i = 0
  while i < n {
    inverse.push(0)
    i += 1
  }
  i = 0
  while i < n {
    inverse[self.mapping[i]] = i
    i += 1
  }
  Permutation::{ mapping: inverse }
}

///|
pub fn Permutation::ascents(self : Permutation) -> Array[Int] {
  let ascents = Array::new()
  let n = self.mapping.length()
  let mut i = 0
  while i + 1 < n {
    if self.mapping[i] < self.mapping[i + 1] {
      ascents.push(i)
    }
    i += 1
  }
  ascents
}

///|
pub fn Permutation::descents(self : Permutation) -> Array[Int] {
  let descents = Array::new()
  let n = self.mapping.length()
  let mut i = 0
  while i + 1 < n {
    if self.mapping[i] > self.mapping[i + 1] {
      descents.push(i)
    }
    i += 1
  }
  descents
}

///|
pub fn Permutation::cycles(self : Permutation) -> Array[Array[Int]] {
  let cycles = Array::new()
  let n = self.mapping.length()
  if n == 0 {
    return cycles
  }
  let visited = Array::new()
  let mut i = 0
  while i < n {
    visited.push(false)
    i += 1
  }
  i = 0
  while i < n {
    if visited[i] {
      i += 1
      continue
    }
    let cycle = Array::new()
    let mut current = i
    while !visited[current] {
      cycle.push(current)
      visited[current] = true
      current = self.mapping[current]
    }
    let rotated = rotate_cycle_to_min(cycle)
    cycles.push(rotated)
    i += 1
  }
  cycles
}

///|
pub fn Permutation::cycle_structure(self : Permutation) -> Array[Int] {
  let cycles = self.cycles()
  let lengths = Array::new()
  for c in cycles {
    lengths.push(c.length())
  }
  sort_ints(lengths)
}

///|
pub fn Permutation::cyclic_form(self : Permutation) -> String {
  let cycles = self.cycles()
  if cycles.length() == 0 {
    return "()"
  }
  let parts = Array::new()
  for cycle in cycles {
    let mut text = "("
    let len = cycle.length()
    let mut i = 0
    while i < len {
      if i > 0 {
        text = text + " "
      }
      text = text + cycle[i].to_string()
      i += 1
    }
    text = text + ")"
    parts.push(text)
  }
  join_strings(parts, "")
}

///|
pub fn Permutation::parity(self : Permutation) -> Int {
  let n = self.mapping.length()
  let mut sign = 1
  let mut i = 0
  while i < n {
    let mut j = i + 1
    while j < n {
      if self.mapping[i] > self.mapping[j] {
        sign = -sign
      }
      j += 1
    }
    i += 1
  }
  sign
}

///|
pub fn Permutation::commutator(
  self : Permutation,
  other : Permutation,
) -> Permutation {
  if self.mapping.length() == 0 ||
    self.mapping.length() != other.mapping.length() {
    return Permutation::{ mapping: Array::new() }
  }
  let temp = self.compose(other)
  let temp = temp.compose(self.inverse())
  temp.compose(other.inverse())
}

///|
pub fn Permutation::commutes_with(
  self : Permutation,
  other : Permutation,
) -> Bool {
  if self.mapping.length() != other.mapping.length() {
    return false
  }
  let a = self.compose(other)
  let b = other.compose(self)
  partitions_equal(a.mapping, b.mapping)
}

///|
pub fn Permutation::rank_lex(self : Permutation) -> Int {
  let n = self.mapping.length()
  let facts = factorials(n)
  let mut rank = 0
  let used = Array::new()
  let mut i = 0
  while i < n {
    used.push(false)
    i += 1
  }
  i = 0
  while i < n {
    let mut count = 0
    let mut v = 0
    while v < self.mapping[i] {
      if !used[v] {
        count += 1
      }
      v += 1
    }
    rank = rank + count * facts[n - 1 - i]
    used[self.mapping[i]] = true
    i += 1
  }
  rank
}

///|
pub fn Permutation::unrank_lex(size : Int, rank : Int) -> Permutation {
  if size <= 0 {
    return Permutation::{ mapping: Array::new() }
  }
  let facts = factorials(size)
  let mut remaining = rank % facts[size]
  let mut available = Array::new()
  let mut i = 0
  while i < size {
    available.push(i)
    i += 1
  }
  let mapping = Array::new()
  let mut pos = 0
  while pos < size {
    let block = facts[size - 1 - pos]
    let idx = remaining / block
    remaining = remaining % block
    let (value, next_available) = pick_available(available, idx)
    mapping.push(value)
    available = next_available
    pos += 1
  }
  Permutation::{ mapping, }
}

///|
pub fn Permutation::next_lex(self : Permutation) -> Permutation {
  let n = self.mapping.length()
  if n == 0 {
    return self
  }
  let facts = factorials(n)
  let rank = self.rank_lex()
  let next_rank = (rank + 1) % facts[n]
  Permutation::unrank_lex(n, next_rank)
}

///|
pub fn Permutation::prev_lex(self : Permutation) -> Permutation {
  let n = self.mapping.length()
  if n == 0 {
    return self
  }
  let facts = factorials(n)
  let rank = self.rank_lex()
  let prev_rank = if rank == 0 { facts[n] - 1 } else { rank - 1 }
  Permutation::unrank_lex(n, prev_rank)
}

///|
pub struct PermutationGroup {
  generators : Array[Permutation]
  degree : Int
}

///|
pub fn PermutationGroup::new(
  generators : Array[Permutation],
) -> PermutationGroup {
  if generators.length() == 0 {
    return PermutationGroup::{ generators: Array::new(), degree: 0 }
  }
  let degree = generators[0].length()
  let mut i = 0
  while i < generators.length() {
    if generators[i].length() != degree {
      return PermutationGroup::{ generators: Array::new(), degree: 0 }
    }
    i += 1
  }
  PermutationGroup::{ generators, degree }
}

///|
pub fn PermutationGroup::identity(self : PermutationGroup) -> Permutation {
  Permutation::identity(self.degree)
}

///|
pub fn PermutationGroup::order(self : PermutationGroup) -> Int {
  let closure = closure(self.generators, self.degree)
  closure.length()
}

///|
pub fn PermutationGroup::base(self : PermutationGroup) -> Array[Int] {
  let base = Array::new()
  let mut i = 0
  while i < self.degree {
    base.push(i)
    i += 1
  }
  base
}

///|
pub fn PermutationGroup::schreier_sims(
  self : PermutationGroup,
) -> PermutationGroup {
  self
}

///|
pub fn PermutationGroup::basic_data(
  self : PermutationGroup,
) -> (
  Array[Array[Int]],
  Array[Array[Permutation]],
  Array[Map[Int, Permutation]],
) {
  let base = self.base()
  let perms = closure(self.generators, self.degree)
  let orbits = Array::new()
  let stabilizers = Array::new()
  let transversals = Array::new()
  let mut current_group = perms
  let mut level = 0
  while level < base.length() {
    let point = base[level]
    let orbit_info = orbit_with_transversal(point, current_group)
    let (orbit, transversal) = orbit_info
    orbits.push(orbit)
    transversals.push(transversal)
    let fixer = filter_stabilizer(current_group, point)
    stabilizers.push(fixer)
    current_group = stabilizers[level]
    level += 1
  }
  (orbits, stabilizers, transversals)
}

///|
pub fn PermutationGroup::basic_orbits(
  self : PermutationGroup,
) -> Array[Array[Int]] {
  let (orbits, _, _) = self.basic_data()
  orbits
}

///|
pub fn PermutationGroup::basic_stabilizers(
  self : PermutationGroup,
) -> Array[Array[Permutation]] {
  let (_, stabilizers, _) = self.basic_data()
  stabilizers
}

///|
pub fn PermutationGroup::basic_transversals(
  self : PermutationGroup,
) -> Array[Map[Int, Permutation]] {
  let (_, _, transversals) = self.basic_data()
  transversals
}

///|
pub fn PermutationGroup::abelian_invariants(
  self : PermutationGroup,
) -> Array[Int] {
  let order = self.order()
  nt_prime_factor_list(order)
}

///|
fn is_valid_permutation(mapping : Array[Int]) -> Bool {
  let n = mapping.length()
  let seen = Array::new()
  let mut i = 0
  while i < n {
    seen.push(false)
    i += 1
  }
  i = 0
  while i < n {
    let v = mapping[i]
    if v < 0 || v >= n {
      return false
    }
    if seen[v] {
      return false
    }
    seen[v] = true
    i += 1
  }
  true
}

///|
fn rotate_cycle_to_min(cycle : Array[Int]) -> Array[Int] {
  let len = cycle.length()
  if len == 0 {
    return cycle
  }
  let mut min_index = 0
  let mut i = 1
  while i < len {
    if cycle[i] < cycle[min_index] {
      min_index = i
    }
    i += 1
  }
  if min_index == 0 {
    return cycle
  }
  let rotated = Array::new()
  let mut pos = 0
  while pos < len {
    rotated.push(cycle[(min_index + pos) % len])
    pos += 1
  }
  rotated
}

///|
fn join_strings(parts : Array[String], sep : String) -> String {
  let mut result = ""
  let len = parts.length()
  let mut i = 0
  while i < len {
    result = result + parts[i]
    if i + 1 < len {
      result = result + sep
    }
    i += 1
  }
  result
}

///|
fn factorials(n : Int) -> Array[Int] {
  let facts = Array::new()
  let mut i = 0
  while i <= n {
    if i == 0 {
      facts.push(1)
    } else {
      facts.push(facts[i - 1] * i)
    }
    i += 1
  }
  facts
}

///|
fn pick_available(avail : Array[Int], index : Int) -> (Int, Array[Int]) {
  let value = avail[index]
  let remaining = Array::new()
  let len = avail.length()
  let mut i = 0
  while i < len {
    if i != index {
      remaining.push(avail[i])
    }
    i += 1
  }
  (value, remaining)
}

///|
pub struct Polyhedron {
  base_corners : Array[Int]
  base_faces : Array[Array[Int]]
  pgroup : Array[Permutation]
  current : Permutation
}

///|
pub fn Polyhedron::new(
  corners : Array[Int],
  faces? : Array[Array[Int]] = Array::new(),
  pgroup? : Array[Permutation] = Array::new(),
) -> Polyhedron {
  let n = corners.length()
  let current = Permutation::identity(n)
  Polyhedron::{ base_corners: corners, base_faces: faces, pgroup, current }
}

///|
pub fn Polyhedron::size(self : Polyhedron) -> Int {
  self.base_corners.length()
}

///|
pub fn Polyhedron::vertices(self : Polyhedron) -> Array[Int] {
  self.corners()
}

///|
pub fn Polyhedron::corners(self : Polyhedron) -> Array[Int] {
  let n = self.base_corners.length()
  let transformed = Array::new()
  let mut i = 0
  while i < n {
    let target = self.current.apply(i)
    if target < 0 || target >= n {
      transformed.push(self.base_corners[i])
    } else {
      transformed.push(self.base_corners[target])
    }
    i += 1
  }
  transformed
}

///|
pub fn Polyhedron::faces(self : Polyhedron) -> Array[Array[Int]] {
  let mapped = Array::new()
  for face in self.base_faces {
    let transformed = Array::new()
    for v in face {
      let image = self.current.apply(v)
      transformed.push(image)
    }
    mapped.push(transformed)
  }
  mapped
}

///|
pub fn Polyhedron::edges(self : Polyhedron) -> Array[(Int, Int)] {
  let edges = Array::new()
  let seen : Map[String, Bool] = {}
  for face in self.faces() {
    let len = face.length()
    if len < 2 {
      continue
    }
    let mut i = 0
    while i < len {
      let a = face[i]
      let b = face[(i + 1) % len]
      let edge = if a < b { (a, b) } else { (b, a) }
      let key = edge.0.to_string() + "-" + edge.1.to_string()
      match seen.get(key) {
        Some(_) => ()
        None => {
          seen.set(key, true)
          edges.push(edge)
        }
      }
      i += 1
    }
  }
  edges
}

///|
pub fn Polyhedron::array_form(self : Polyhedron) -> Array[Int] {
  self.current.array_form()
}

///|
pub fn Polyhedron::cyclic_form(self : Polyhedron) -> String {
  self.current.cyclic_form()
}

///|
pub fn Polyhedron::rotate(self : Polyhedron, perm : Permutation) -> Polyhedron {
  let composed = perm.compose(self.current)
  Polyhedron::{
    base_corners: self.base_corners,
    base_faces: self.base_faces,
    pgroup: self.pgroup,
    current: composed,
  }
}

///|
pub fn Polyhedron::rotate_by_index(
  self : Polyhedron,
  index : Int,
) -> Polyhedron {
  if index < 0 || index >= self.pgroup.length() {
    return self
  }
  self.rotate(self.pgroup[index])
}

///|
pub fn Polyhedron::reset(self : Polyhedron) -> Polyhedron {
  Polyhedron::{
    base_corners: self.base_corners,
    base_faces: self.base_faces,
    pgroup: self.pgroup,
    current: Permutation::identity(self.size()),
  }
}

///|
fn closure(generators : Array[Permutation], degree : Int) -> Array[Permutation] {
  let perms = Array::new()
  let seen : Map[String, Bool] = {}
  let id = Permutation::identity(degree)
  perms.push(id)
  seen.set(id.array_form().to_string(), true)
  let queue = Array::new()
  queue.push(id)
  let gens = generators
  while queue.length() > 0 {
    let current = queue[queue.length() - 1]
    let _ = queue.remove(queue.length() - 1)
    for g in gens {
      let prod = current.compose(g)
      let key = prod.array_form().to_string()
      match seen.get(key) {
        Some(_) => ()
        None => {
          seen.set(key, true)
          perms.push(prod)
          queue.push(prod)
        }
      }
      let prod2 = g.compose(current)
      let key2 = prod2.array_form().to_string()
      match seen.get(key2) {
        Some(_) => ()
        None => {
          seen.set(key2, true)
          perms.push(prod2)
          queue.push(prod2)
        }
      }
    }
  }
  perms
}

///|
fn orbit_with_transversal(
  point : Int,
  group : Array[Permutation],
) -> (Array[Int], Map[Int, Permutation]) {
  let orbit = Array::new()
  let trans : Map[Int, Permutation] = {}
  for g in group {
    let image = g.apply(point)
    if !trans.contains(image) {
      trans.set(image, g)
      orbit.push(image)
    }
  }
  let sorted = sort_ints(orbit)
  (sorted, trans)
}

///|
fn filter_stabilizer(
  group : Array[Permutation],
  point : Int,
) -> Array[Permutation] {
  let result = Array::new()
  for g in group {
    if g.apply(point) == point {
      result.push(g)
    }
  }
  result
}

///|
pub fn random_integer_partition(n : Int, seed? : Int = 0) -> Array[Int] {
  if n <= 0 {
    return Array::new()
  }
  let parts = Array::new()
  let mut remaining = n
  let mut state = if seed != 0 { seed } else { n + 7 }
  if state < 0 {
    state = -state
  }
  while remaining > 0 {
    state = (state * 1103515245 + 12345) & 0x7fffffff
    let pick = state % remaining + 1
    parts.push(pick)
    remaining -= pick
  }
  normalize_parts(parts)
}

///|
pub fn rgs_generalized(m : Int) -> Array[Array[Int]] {
  generate_rgs_list(m)
}

///|
pub fn rgs_enum(m : Int) -> Int {
  let rgs_list = generate_rgs_list(m)
  rgs_list.length()
}

///|
pub fn rgs_rank(rgs : Array[Int]) -> Int {
  let m = rgs.length()
  let all = generate_rgs_list(m)
  find_partition_index(all, rgs)
}

///|
pub fn rgs_unrank(rank : Int, m : Int) -> Array[Int] {
  if rank < 0 {
    return Array::new()
  }
  let all = generate_rgs_list(m)
  if rank >= all.length() {
    Array::new()
  } else {
    all[rank]
  }
}

///|
fn generate_rgs_list(length : Int) -> Array[Array[Int]] {
  let acc = Array::new()
  if length <= 0 {
    return acc
  }
  let start = Array::new()
  start.push(0)
  rgs_backtrack(1, 0, start, acc, length)
}

///|
fn rgs_backtrack(
  index : Int,
  max_value : Int,
  current : Array[Int],
  acc : Array[Array[Int]],
  length : Int,
) -> Array[Array[Int]] {
  if index == length {
    let base = acc
    base.push(current)
    return base
  }
  let mut result = acc
  let mut next = 0
  while next <= max_value + 1 {
    let next_current = current.copy()
    next_current.push(next)
    let next_max = if next > max_value { next } else { max_value }
    result = rgs_backtrack(index + 1, next_max, next_current, result, length)
    next += 1
  }
  result
}

///|
pub struct Prufer {
  seq : Array[Int]
}

///|
pub fn Prufer::new(seq : Array[Int]) -> Prufer {
  Prufer::{ seq, }
}

///|
pub fn Prufer::size(self : Prufer) -> Int {
  self.seq.length() + 2
}

///|
pub fn Prufer::nodes(self : Prufer) -> Array[Int] {
  let n = self.size()
  let nodes = Array::new()
  let mut i = 0
  while i < n {
    nodes.push(i)
    i += 1
  }
  nodes
}

///|
pub fn Prufer::prufer_repr(self : Prufer) -> Array[Int] {
  self.seq
}

///|
pub fn Prufer::tree_repr(self : Prufer) -> Array[(Int, Int)] {
  self.edges()
}

///|
pub fn Prufer::edges(self : Prufer) -> Array[(Int, Int)] {
  to_tree(self.seq)
}

///|
pub fn Prufer::next(self : Prufer, delta? : Int = 1) -> Prufer {
  let n = self.size()
  let len = self.seq.length()
  if len == 0 {
    return self
  }
  let total = pow_int(n, len)
  let rank = prufer_rank(self.seq, n)
  let next_rank = (rank + delta) % total
  Prufer::unrank(next_rank, n)
}

///|
pub fn Prufer::prev(self : Prufer, delta? : Int = 1) -> Prufer {
  let n = self.size()
  let len = self.seq.length()
  if len == 0 {
    return self
  }
  let total = pow_int(n, len)
  let rank = prufer_rank(self.seq, n)
  let mut new_rank = rank - delta % total
  if new_rank < 0 {
    new_rank += total
  }
  Prufer::unrank(new_rank, n)
}

///|
pub fn Prufer::prufer_rank(self : Prufer) -> Int {
  prufer_rank(self.seq, self.size())
}

///|
pub fn Prufer::rank(self : Prufer) -> Int {
  self.prufer_rank()
}

///|
pub fn Prufer::unrank(rank : Int, n : Int) -> Prufer {
  let seq = unrank_prufer(rank, n)
  Prufer::{ seq, }
}

///|
pub fn to_tree(seq : Array[Int]) -> Array[(Int, Int)] {
  let len = seq.length()
  let n = len + 2
  if n <= 1 {
    return Array::new()
  }
  let degree = Array::new()
  let mut i = 0
  while i < n {
    degree.push(1)
    i += 1
  }
  for v in seq {
    if v >= 0 && v < n {
      degree[v] = degree[v] + 1
    }
  }
  let edges = Array::new()
  let mut seq_index = 0
  while seq_index < len {
    let v = seq[seq_index]
    let leaf = find_smallest_leaf(degree)
    let edge = if leaf < v { (leaf, v) } else { (v, leaf) }
    edges.push(edge)
    degree[leaf] = degree[leaf] - 1
    degree[v] = degree[v] - 1
    seq_index += 1
  }
  let mut u = -1
  let mut w = -1
  i = 0
  while i < n {
    if degree[i] == 1 {
      if u == -1 {
        u = i
      } else {
        w = i
        break
      }
    }
    i += 1
  }
  if u != -1 && w != -1 {
    let edge = if u < w { (u, w) } else { (w, u) }
    edges.push(edge)
  }
  edges
}

///|
pub fn to_prufer(tree : Array[(Int, Int)], n : Int) -> Array[Int] {
  if n <= 2 {
    return Array::new()
  }
  let degree = Array::new()
  let mut i = 0
  while i < n {
    degree.push(0)
    i += 1
  }
  for edge in tree {
    let (a, b) = edge
    if a >= 0 && a < n && b >= 0 && b < n {
      degree[a] = degree[a] + 1
      degree[b] = degree[b] + 1
    }
  }
  let seq = Array::new()
  let used = Array::new()
  let mut idx_init = 0
  while idx_init < tree.length() {
    used.push(false)
    idx_init += 1
  }
  let mut step = 0
  while step < n - 2 {
    let leaf = find_smallest_leaf(degree)
    let mut neighbor = -1
    let mut idx = 0
    while idx < tree.length() {
      if !used[idx] {
        let (a, b) = tree[idx]
        if a == leaf {
          neighbor = b
          used[idx] = true
          break
        } else if b == leaf {
          neighbor = a
          used[idx] = true
          break
        }
      }
      idx += 1
    }
    if neighbor == -1 {
      break
    }
    seq.push(neighbor)
    degree[leaf] = degree[leaf] - 1
    degree[neighbor] = degree[neighbor] - 1
    step += 1
  }
  seq
}

///|
pub fn nodes_from_edges(tree : Array[(Int, Int)]) -> Int {
  let seen : Map[Int, Bool] = {}
  for edge in tree {
    let (a, b) = edge
    seen.set(a, true)
    seen.set(b, true)
  }
  seen.length()
}

///|
fn find_smallest_leaf(degree : Array[Int]) -> Int {
  let len = degree.length()
  let mut i = 0
  while i < len {
    if degree[i] == 1 {
      return i
    }
    i += 1
  }
  -1
}

///|
fn prufer_rank(seq : Array[Int], n : Int) -> Int {
  let len = seq.length()
  let mut rank = 0
  let mut i = 0
  while i < len {
    rank = rank * n + seq[i]
    i += 1
  }
  rank
}

///|
fn unrank_prufer(rank : Int, n : Int) -> Array[Int] {
  if n <= 2 {
    return Array::new()
  }
  let len = n - 2
  let seq = Array::new()
  let mut value = rank
  let mut i = 0
  while i < len {
    seq.push(0)
    i += 1
  }
  let mut pos = len - 1
  while pos >= 0 {
    seq[pos] = value % n
    value = value / n
    if pos == 0 {
      break
    }
    pos -= 1
  }
  seq
}

///|
pub fn sort_edges(edges : Array[(Int, Int)]) -> Array[(Int, Int)] {
  let len = edges.length()
  let mut i = 0
  while i < len {
    let mut min_index = i
    let mut j = i + 1
    while j < len {
      let (a1, b1) = edges[min_index]
      let (a2, b2) = edges[j]
      if a2 < a1 || (a2 == a1 && b2 < b1) {
        min_index = j
      }
      j += 1
    }
    if min_index != i {
      let temp = edges[i]
      edges[i] = edges[min_index]
      edges[min_index] = temp
    }
    i += 1
  }
  edges
}

///|
pub struct GrayCode {
  n : Int
  rank : Int
}

///|
pub fn GrayCode::new(n : Int, start? : Int = 0, rank? : Int = 0) -> GrayCode {
  let size = if n < 0 { 0 } else { n }
  let total = pow_int(2, size)
  let r = if rank != 0 { rank } else { start }
  let mut rr = r
  if total > 0 {
    rr = (rr % total + total) % total
  }
  GrayCode::{ n: size, rank: rr }
}

///|
pub fn GrayCode::current(self : GrayCode) -> String {
  let value = self.rank ^ (self.rank >> 1)
  int_to_bitstring(value, self.n)
}

///|
pub fn GrayCode::n(self : GrayCode) -> Int {
  self.n
}

///|
pub fn GrayCode::selections(self : GrayCode) -> Int {
  self.n
}

///|
pub fn GrayCode::next(self : GrayCode, delta? : Int = 1) -> GrayCode {
  if self.n == 0 {
    return self
  }
  let total = pow_int(2, self.n)
  let mut r = (self.rank + delta) % total
  if r < 0 {
    r += total
  }
  GrayCode::{ n: self.n, rank: r }
}

///|
pub fn GrayCode::skip(self : GrayCode, delta? : Int = 1) -> GrayCode {
  self.next(delta~)
}

///|
pub fn GrayCode::rank(self : GrayCode) -> Int {
  self.rank
}

///|
pub fn GrayCode::unrank(n : Int, rank : Int) -> GrayCode {
  GrayCode::new(n, rank~)
}

///|
pub fn generate_gray(n : Int, start? : Int = 0) -> Array[String] {
  let size = if n < 0 { 0 } else { n }
  let total = pow_int(2, size)
  let mut r = start
  if total > 0 {
    r = (r % total + total) % total
  }
  let codes = Array::new()
  let mut i = 0
  while i < total {
    let gc = GrayCode::new(size, rank=r + i)
    codes.push(gc.current())
    i += 1
  }
  codes
}

///|
pub fn random_bitstring(n : Int, seed? : Int = 0) -> String {
  if n <= 0 {
    return ""
  }
  let mut state = if seed != 0 { seed } else { n * 7919 + 11 }
  if state < 0 {
    state = -state
  }
  let mut i = 0
  let mut bits = ""
  while i < n {
    state = (state * 1103515245 + 12345) & 0x7fffffff
    let bit = state % 2
    bits = bits + bit.to_string()
    i += 1
  }
  bits
}

///|
pub fn bin_to_gray(bitstring : String) -> String {
  let n = bitstring.length()
  if n == 0 {
    return ""
  }
  let mut result = ""
  let mut i = 0
  while i < n {
    let b = if bitstring.code_unit_at(i) == '1' { 1 } else { 0 }
    let prev = if i == 0 {
      0
    } else if bitstring.code_unit_at(i - 1) == '1' {
      1
    } else {
      0
    }
    let g = b ^ prev
    result = result + g.to_string()
    i += 1
  }
  result
}

///|
pub fn gray_to_bin(bitstring : String) -> String {
  let n = bitstring.length()
  if n == 0 {
    return ""
  }
  let mut result = ""
  let mut current = 0
  let mut i = 0
  while i < n {
    let g = if bitstring.code_unit_at(i) == '1' { 1 } else { 0 }
    current = current ^ g
    result = result + current.to_string()
    i += 1
  }
  result
}

///|
pub fn get_subset_from_bitstring(
  items : Array[Int],
  bitstring : String,
) -> Array[Int] {
  let subset = Array::new()
  let len = bitstring.length()
  let mut i = 0
  while i < len && i < items.length() {
    if bitstring.code_unit_at(i) == '1' {
      subset.push(items[i])
    }
    i += 1
  }
  subset
}

///|
pub fn graycode_subsets(items : Array[Int]) -> Array[Array[Int]] {
  let n = items.length()
  let codes = generate_gray(n)
  let subsets = Array::new()
  for code in codes {
    subsets.push(get_subset_from_bitstring(items, code))
  }
  subsets
}

///|
fn int_to_bitstring(value : Int, width : Int) -> String {
  if width <= 0 {
    return ""
  }
  let bits = Array::new()
  let mut i = 0
  while i < width {
    bits.push('0')
    i += 1
  }
  let mut v = value
  i = width - 1
  while i >= 0 {
    let bit = v % 2
    bits[i] = if bit == 0 { '0' } else { '1' }
    v = v / 2
    if i == 0 {
      break
    }
    i -= 1
  }
  let mut s = ""
  i = 0
  while i < width {
    s = s + bits[i].to_string()
    i += 1
  }
  s
}

///|
pub struct Subset {
  subset : Array[Int]
  superset : Array[Int]
}

///|
pub fn Subset::new(subset : Array[Int], superset : Array[Int]) -> Subset {
  let filtered = Array::new()
  for v in subset {
    let mut found = false
    for s in superset {
      if s == v {
        found = true
        break
      }
    }
    if found {
      filtered.push(v)
    }
  }
  Subset::{ subset: filtered, superset }
}

///|
pub fn Subset::subset(self : Subset) -> Array[Int] {
  self.subset
}

///|
pub fn Subset::superset(self : Subset) -> Array[Int] {
  self.superset
}

///|
pub fn Subset::size(self : Subset) -> Int {
  self.subset.length()
}

///|
pub fn Subset::superset_size(self : Subset) -> Int {
  self.superset.length()
}

///|
pub fn Subset::cardinality(self : Subset) -> Int {
  self.size()
}

///|
pub fn bitlist_from_subset(
  subset : Array[Int],
  superset : Array[Int],
) -> String {
  let mut bits = ""
  let n = superset.length()
  let mut i = 0
  while i < n {
    let v = superset[i]
    let mut found = false
    for s in subset {
      if s == v {
        found = true
        break
      }
    }
    let bit = if found { "1" } else { "0" }
    bits = bits + bit
    i += 1
  }
  bits
}

///|
pub fn subset_from_bitlist(
  superset : Array[Int],
  bitlist : String,
) -> Array[Int] {
  let subset = Array::new()
  let n = superset.length()
  let len = bitlist.length()
  let mut i = 0
  while i < n && i < len {
    if bitlist.code_unit_at(i) == '1' {
      subset.push(superset[i])
    }
    i += 1
  }
  subset
}

///|
pub fn subset_indices(subset : Array[Int], superset : Array[Int]) -> Array[Int] {
  let idx = Array::new()
  let n = superset.length()
  let mut i = 0
  while i < n {
    for v in subset {
      if v == superset[i] {
        idx.push(i)
        break
      }
    }
    i += 1
  }
  idx
}

///|
pub fn iterate_binary(superset : Array[Int]) -> Array[Array[Int]] {
  let n = superset.length()
  let total = pow_int(2, n)
  let subsets = Array::new()
  let mut rank = 0
  while rank < total {
    subsets.push(unrank_binary(rank, superset))
    rank += 1
  }
  subsets
}

///|
pub fn iterate_graycode(superset : Array[Int]) -> Array[Array[Int]] {
  let n = superset.length()
  let codes = generate_gray(n)
  let subsets = Array::new()
  for code in codes {
    subsets.push(subset_from_bitlist(superset, code))
  }
  subsets
}

///|
pub fn next_binary(
  subset : Array[Int],
  superset : Array[Int],
  delta? : Int = 1,
) -> Array[Int] {
  let n = superset.length()
  let total = pow_int(2, n)
  let rank = rank_binary(subset, superset)
  let mut r = (rank + delta) % total
  if r < 0 {
    r += total
  }
  unrank_binary(r, superset)
}

///|
pub fn prev_binary(
  subset : Array[Int],
  superset : Array[Int],
  delta? : Int = 1,
) -> Array[Int] {
  next_binary(subset, superset, delta=-delta)
}

///|
pub fn next_gray(
  subset : Array[Int],
  superset : Array[Int],
  delta? : Int = 1,
) -> Array[Int] {
  let n = superset.length()
  let total = pow_int(2, n)
  let rank = rank_gray(subset, superset)
  let mut r = (rank + delta) % total
  if r < 0 {
    r += total
  }
  unrank_gray(r, superset)
}

///|
pub fn prev_gray(
  subset : Array[Int],
  superset : Array[Int],
  delta? : Int = 1,
) -> Array[Int] {
  next_gray(subset, superset, delta=-delta)
}

///|
pub fn rank_binary(subset : Array[Int], superset : Array[Int]) -> Int {
  let bits = bitlist_from_subset(subset, superset)
  bitstring_to_int(bits)
}

///|
pub fn unrank_binary(rank : Int, superset : Array[Int]) -> Array[Int] {
  let n = superset.length()
  let bitstring = int_to_bitstring(rank, n)
  subset_from_bitlist(superset, bitstring)
}

///|
pub fn rank_gray(subset : Array[Int], superset : Array[Int]) -> Int {
  let rank_b = rank_binary(subset, superset)
  rank_b ^ (rank_b >> 1)
}

///|
pub fn unrank_gray(rank : Int, superset : Array[Int]) -> Array[Int] {
  let n = superset.length()
  let bin_value = gray_to_binary_int(rank, n)
  unrank_binary(bin_value, superset)
}

///|
pub fn rank_lexicographic(subset : Array[Int], superset : Array[Int]) -> Int {
  rank_binary(subset, superset)
}

///|
pub fn unrank_lexicographic(rank : Int, superset : Array[Int]) -> Array[Int] {
  unrank_binary(rank, superset)
}

///|
pub fn bitlist_to_int(bitstring : String) -> Int {
  bitstring_to_int(bitstring)
}

///|
fn bitstring_to_int(bits : String) -> Int {
  let len = bits.length()
  let mut value = 0
  let mut i = 0
  while i < len {
    let bit = if bits.code_unit_at(i) == '1' { 1 } else { 0 }
    value = value * 2 + bit
    i += 1
  }
  value
}

///|
fn gray_to_binary_int(gray : Int, width : Int) -> Int {
  if width <= 0 {
    return 0
  }
  let mut result = 0
  let mut mask = gray
  while mask > 0 {
    result = result ^ mask
    mask = mask >> 1
  }
  result
}

///|
pub fn cycle_length(
  f : (Int) -> Int,
  x0 : Int,
  nmax? : Int = -1,
  values? : Bool = false,
) -> Int {
  let _ = values
  let mut tortoise = f(x0)
  let mut hare = f(f(x0))
  let mut steps = 0
  while tortoise != hare {
    if nmax > 0 && steps >= nmax {
      return 0
    }
    tortoise = f(tortoise)
    hare = f(f(hare))
    steps += 1
  }
  tortoise = x0
  while tortoise != hare {
    tortoise = f(tortoise)
    hare = f(hare)
  }
  let mut lam = 1
  hare = f(tortoise)
  while tortoise != hare {
    hare = f(hare)
    lam += 1
  }
  lam
}

///|
pub fn ksubsets(iterable : Array[Int], k : Int) -> Array[Array[Int]] {
  let len = iterable.length()
  if k < 0 || k > len {
    return Array::new()
  }
  let result = Array::new()
  let current = Array::new()
  ksubsets_backtrack(iterable, k, 0, current, result)
}

///|
fn ksubsets_backtrack(
  iterable : Array[Int],
  k : Int,
  start : Int,
  current : Array[Int],
  acc : Array[Array[Int]],
) -> Array[Array[Int]] {
  if current.length() == k {
    let base = acc
    base.push(current)
    return base
  }
  let len = iterable.length()
  let mut acc_mut = acc
  let mut i = start
  while i < len {
    let next = current.copy()
    next.push(iterable[i])
    acc_mut = ksubsets_backtrack(iterable, k, i + 1, next, acc_mut)
    i += 1
  }
  acc_mut
}

///|
pub fn symmetric_group(n : Int) -> PermutationGroup {
  if n <= 0 {
    return PermutationGroup::new([])
  }
  let gens : Array[Permutation] = Array::new()
  let mut i = 0
  while i + 1 < n {
    let mapping : Array[Int] = Array::new()
    let mut j = 0
    while j < n {
      mapping.push(j)
      j += 1
    }
    let temp = mapping[i]
    mapping[i] = mapping[i + 1]
    mapping[i + 1] = temp
    gens.push(Permutation::new(mapping))
    i += 1
  }
  PermutationGroup::new(gens)
}

///|
pub fn cyclic_group(n : Int) -> PermutationGroup {
  if n <= 0 {
    return PermutationGroup::new([])
  }
  let mapping : Array[Int] = Array::new()
  let mut i = 0
  while i < n {
    mapping.push((i + 1) % n)
    i += 1
  }
  let gen = Permutation::new(mapping)
  PermutationGroup::new([gen])
}

///|
pub fn dihedral_group(n : Int) -> PermutationGroup {
  if n <= 0 {
    return PermutationGroup::new([])
  }
  let rotation : Array[Int] = Array::new()
  let reflection : Array[Int] = Array::new()
  let mut i = 0
  while i < n {
    rotation.push((i + 1) % n)
    reflection.push(n - 1 - i)
    i += 1
  }
  let rot = Permutation::new(rotation)
  let refp = Permutation::new(reflection)
  PermutationGroup::new([rot, refp])
}

///|
pub fn alternating_group(n : Int) -> PermutationGroup {
  if n <= 0 {
    return PermutationGroup::new([])
  }
  let sym = symmetric_group(n)
  let all = closure(sym.generators, n)
  let evens : Array[Permutation] = Array::new()
  for p in all {
    if p.parity() == 1 {
      evens.push(p)
    }
  }
  PermutationGroup::new(evens)
}
