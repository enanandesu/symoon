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
