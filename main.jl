
# Day 1

function solve01(file)
  values = parse.(Int, readlines(file))
  for x in values, y in values
    if x + y == 2020 && x <= y
      return x * y
    end
  end
end

@assert solve01("data/day01-test.txt") == 514579
@assert solve01("data/day01.txt") == 1007104

function solve02(file)
  values = parse.(Int, readlines(file))
  for x in values, y in values, z in values
    if x + y + z == 2020 && x <= y <= z
      return x * y * z
    end
  end
end

@assert solve02("data/day01-test.txt") == 241861950
@assert solve02("data/day01.txt") == 18847752


# Day 2

function solve03(file)
  lines = readlines(file)
  pat = r"^([0-9]+)-([0-9]+) ([a-z]): ([a-z]+)$"
  count(lines) do line
    m = match(pat, line)
    min, max = parse.(Int, m.captures[1:2])
    letter = m.captures[3][1]
    pwd = m.captures[4]
    min <= count(isequal(letter), pwd) <= max
  end
end

@assert solve03("data/day02-test.txt") == 2
@assert solve03("data/day02.txt") == 580

function solve04(file)
  lines = readlines(file)
  pat = r"^([0-9]+)-([0-9]+) ([a-z]): ([a-z]+)$"
  count(lines) do line
    m = match(pat, line)
    min, max = parse.(Int, m.captures[1:2])
    letter = m.captures[3][1]
    pwd = m.captures[4]
    count(isequal(letter),  pwd[[min, max]]) == 1
  end
end

@assert solve04("data/day02-test.txt") == 1
@assert solve04("data/day02.txt") == 611


# Day 3

parse_forest(file) = mapreduce(vcat, readlines(file)) do line
  map(isequal('#'), collect(line))'
end

straight_path(size, (dx, dy)) = map(0:div(size[1]-1, dy)) do i
  CartesianIndex(1 + i*dy, 1 + (i*dx % size[2]))
end

function solve05(file)
  landscape = parse_forest(file) 
  indices = straight_path(size(landscape), (3, 1))
  sum(landscape[indices])
end

@assert solve05("data/day03-test.txt") == 7
@assert solve05("data/day03.txt") == 148

function solve06(file)
  landscape = parse_forest(file)
  slopes = [(1,1), (3,1), (5,1), (7,1), (1,2)]
  trees = map(slopes) do slope
    indices = straight_path(size(landscape), slope)
    sum(landscape[indices])
  end
  prod(trees)
end

@assert solve06("data/day03-test.txt") == 336
@assert solve06("data/day03.txt") == 727923200


# Day 4

function parse_passports(file)
  map(split(read(file, String), r"\n\n+", keepempty=false)) do str
    pairs = map(eachmatch(r"([a-z]+):([a-zA-Z0-9#]+)", str)) do m
      m.captures[1] => m.captures[2]
    end
    Dict(pairs)
  end
end

function check_keys(passport)
  valid     = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid", "cid"] |> Set
  mandatory = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"] |> Set
  fields    = keys(passport) |> Set
  issubset(mandatory, fields) && issubset(fields, valid)
end

function check_values(passport)

  function valid_height(val)
    m = match(r"([0-9]+)(in|cm)", val)
    if     isnothing(m) false
    elseif m.captures[2] == "cm" 150 <= parse(Int, m.captures[1]) <= 193
    else   59 <= parse(Int, m.captures[1]) <= 76
    end
  end

  tests = [
    ("hgt", val -> valid_height(val)),
    ("byr", val -> occursin(r"^[0-9]{4}$", val) && 1920 <= parse(Int, val) <= 2002),
    ("iyr", val -> occursin(r"^[0-9]{4}$", val) && 2010 <= parse(Int, val) <= 2020),
    ("eyr", val -> occursin(r"^[0-9]{4}$", val) && 2020 <= parse(Int, val) <= 2030),
    ("hcl", val -> occursin(r"^#[0-9a-f]{6}$", val)),
    ("ecl", val -> occursin(r"amb|blu|brn|gry|grn|hzl|oth", val)),
    ("pid", val -> occursin(r"^[0-9]{9}$", val)) ]

  all(t -> t[2](passport[t[1]]), tests)
end

function solve07(file)
  passports = parse_passports(file)
  count(check_keys, passports)
end

@assert solve07("data/day04-test.txt") == 2
@assert solve07("data/day04.txt") == 260

function solve08(file)
  passports = parse_passports(file)
  count(p -> check_keys(p) && check_values(p), passports)
end

@assert solve08("data/day04.txt") == 153


# Day 5

function parse_boarding_pass(str)
  lookup(str, dict) = parse(Int, map(c -> dict[c], str), base = 2)
  m = match(r"^((?:F|B){7})((?:R|L){3})", str)
  row = lookup(m.captures[1], Dict('F'=>'0', 'B'=>'1'))
  col = lookup(m.captures[2], Dict('L'=>'0', 'R'=>'1'))
  (row, col)
end

@assert parse_boarding_pass("BFFFBBFRRR") == (70, 7)
@assert parse_boarding_pass("FFFBBBFRRR") == (14, 7)
@assert parse_boarding_pass("BBFFBBFRLL") == (102, 4)

function solve09(file)
  mapreduce(max, readlines(file), init=0) do str
    pass = parse_boarding_pass(str)
    pass[1] * 8 + pass[2]
  end
end

@assert solve09("data/day05.txt") == 813

function solve10(file)
  ids = map(readlines(file)) do str
    pass = parse_boarding_pass(str)
    pass[1] * 8 + pass[2]
  end
  min_id = 8
  max_id = div(maximum(ids), 8) * 8 - 1
  sids = ids[(ids .>= min_id) .& (ids .<= max_id)] |> sort
  idx = findfirst(x -> x > 1, sids[2:end] - sids[1:end-1]) # +-1 exists
  id = sids[idx] + 1
  @assert !(id in ids)
  id
end

@assert solve10("data/day05.txt") == 612


# Day 6

function parse_questionairs(file)
  map(split(read(file, String), r"\n\n+", keepempty=false)) do str
    # Do not have to use Set(collect(x)) here, since intersect and union
    # also works as intended for normal arrays, and performance stays
    # the same
    map(x -> collect(x), split(str, "\n", keepempty=false))
  end
end

function solve11(file)
  data = map(q -> union(q...), parse_questionairs(file))
  sum(length, data)
end

@assert solve11("data/day06-test.txt") == 11
@assert solve11("data/day06.txt") == 6930

function solve12(file)
  data = map(q -> intersect(q...), parse_questionairs(file))
  sum(length, data)
end

@assert solve12("data/day06-test.txt") == 6
@assert solve12("data/day06.txt") == 3585


# Day 7

function parse_bagsicon(file)
  pairs = map(readlines(file)) do line
    parent, rest = split(line,  " bags contain ")
    children = map(split(rest, ",")) do child
      m = match(r"([0-9]+) ([a-z]+ [a-z]+)", child)
      if !isnothing(m) parse(Int, m.captures[1]), m.captures[2] end
    end
    parent => filter(!isnothing, children)
  end
  Dict(pairs)
end

function reverse_bagsicon(bc)
  contains = (bag, child) -> any(x -> x[2] == child, bc[bag])
  bags = collect(keys(bc))
  pairs = map(bags) do child
    parents = filter(bag -> contains(bag, child), bags)
    child => parents
  end
  Dict(pairs)
end

function parent_bags(rbc, color)
  parents = rbc[color]
  union(parents, map(x -> parent_bags(rbc, x), parents)...)
end

nparent_bags(rbc, color) = parent_bags(rbc, color) |> length

function solve13(file)
  rbc = parse_bagsicon(file) |> reverse_bagsicon
  nparent_bags(rbc, "shiny gold")
end

@assert solve13("data/day07-test.txt") == 4
@assert solve13("data/day07.txt") == 254

function nchild_bags(bc, color)
  cs = bc[color]
  isempty(cs) ? 0 : sum(c -> c[1] + c[1] * nchild_bags(bc, c[2]), cs)
end

function solve14(file)
  bc = parse_bagsicon(file)
  nchild_bags(bc, "shiny gold")
end

@assert solve14("data/day07-test.txt") == 32
@assert solve14("data/day07-test2.txt") == 126
@assert solve14("data/day07.txt") == 6006


# Day 8

function parse_boot_code(file)
  map(readlines(file)) do line
    op, arg = split(line, " ")
    (op, parse(Int, arg))
  end
end

function run_boot_code(bc)

  boot_instructions =
    [ "acc" => (i, acc, arg) -> (i+1, acc + arg)
    , "jmp" => (i, acc, arg) -> (i+arg, acc)
    , "nop" => (i, acc, arg) -> (i+1, acc)
    ] |> Dict

  len = length(bc)
  visited = zeros(Bool, len)
  i, acc = (1, 0)

  while true
    if     i == len + 1 return acc, 0 # exit code: without error
    elseif i >= len + 2 return acc, 1 # exit code: missed instruction
    elseif visited[i]   return acc, 2 # exit code: infinite loop
    end
    visited[i] = true
    op, arg = bc[i]
    i, acc = boot_instructions[op](i, acc, arg)
  end
end

function solve15(file)
  bc = parse_boot_code(file)
  acc, exit_code = run_boot_code(bc)
  acc
end

@assert solve15("data/day08-test.txt") == 5
@assert solve15("data/day08.txt") == 1727

function repair_boot_code!(bc, i)
  op, arg = bc[i]
  if     op == "jmp" bc[i] = ("nop", arg); bc
  elseif op == "nop" bc[i] = ("jmp", arg); bc
  end
end

function solve16(file)
  bc_faulty = parse_boot_code(file)
  for i in 1:length(bc_faulty)
    bc = repair_boot_code!(bc_faulty |> copy, i)
    isnothing(bc) && continue
    acc, exit_code = run_boot_code(bc)
    exit_code == 0 && return acc
  end
end

@assert solve16("data/day08-test.txt") == 8
@assert solve16("data/day08.txt") == 552


# Day 9

findmap(f, col) = col[findfirst(x -> !isnothing(f(x)), col)] |> f

function check_sum(base, s)
  visited = Set{Int}()
  for x in base
    s - x in visited ? (return true) : push!(visited, x)
  end
  false
end

parse_XMAS(file) = parse.(Int, readlines(file))

attack_XMAS(code, n) = findmap(n+1:length(code)) do i
  check_sum(code[i-n:i-1], code[i]) ? nothing : code[i]
end

function solve17(file, n = 25)
  xmas = parse_XMAS(file)
  attack_XMAS(xmas, n)
end

@assert solve17("data/day09-test.txt", 5) == 127
@assert solve17("data/day09.txt") == 22406676

function find_csum_indices(xmas, idx, target)
  i, s = idx, 0
  while s < target
    s += xmas[i]
    i += 1
  end
  s == target ? (idx:i-1) : nothing
end

function weakness_XMAS(xmas, target)
  range = findmap(i -> find_csum_indices(xmas, i, target), 1:length(xmas))
  minimum(xmas[range]) + maximum(xmas[range])
end

function solve18(file, n = 25)
  xmas   = parse_XMAS(file)
  target = attack_XMAS(xmas, n)
  weakness_XMAS(xmas, target)
end

@assert solve18("data/day09-test.txt", 5) == 62
@assert solve18("data/day09.txt") == 2942387


# Day 9

parse_adapters(file) = parse.(Int, readlines(file)) |> sort

function solve19(file)
  adapters = parse_adapters(file)
  diffs = [adapters; adapters[end] + 3] - [0; adapters]
  count(isequal(1), diffs) * count(isequal(3), diffs)
end

@assert solve19("data/day10-test.txt") == 7 * 5
@assert solve19("data/day10-test2.txt") == 22 * 10
@assert solve19("data/day10.txt") == 2210

# Search for sublists separated by jolt-jumps of 3
# Only need to consider sublists of length at least 3, otherwise there
# is only one configuration (if-clause in the comprehension).
function split_adapters(adapters)
  diffs = [adapters; adapters[end] + 3] - [0; adapters]
  ks    = [0; findall(isequal(3), diffs)]
  vals  = [0; adapters]
  idx   = 1:length(ks)-1
  [ vals[(ks[i]+1):ks[i+1]] for i in idx if ks[i]+2 < ks[i+1] ]
end

# Checked that each sublist after splitting has at most length 5, so one can
# easily count the sub-arrangements by brute force

function count_arrangements(sublist)
  k = length(sublist) - 2
  masks = map( 1:2^k ) do n # all boolean masks of length k
    parse.(Bool, bitstring(n-1)[end-k+1:end] |> collect)
  end
  valid(arr) = all(x -> x <= 3, arr[2:end] - arr[1:end-1])
  count(m -> valid(sublist[[true; m; true]]), masks)
end

function solve20(file)
  adapters = parse_adapters(file)
  sublists = split_adapters(adapters)
  prod(count_arrangements, sublists)
end

@assert solve20("data/day10-test.txt") == 8
@assert solve20("data/day10-test2.txt") == 19208
@assert solve20("data/day10.txt") == 7086739046912


# Day 11

function parse_seat_config(file)
  dict = Dict('#' => 1, 'L' => 2, '.' => 3)
  mapreduce(vcat, readlines(file)) do line
    map(x -> dict[x], collect(line))'
  end
end

function analyze_seat(sc, (i, j))
  n, m = size(sc)
  sx, sy = max(i-1, 1):min(i+1, n), max(j-1, 1):min(j+1, m)
  nbh = sc[sx,sy]
  count(isequal(1), nbh) - isequal(sc[i,j])(1)
end

function evolve_seat_config(sc, analyze, tol)
  map(CartesianIndices(sc)) do idx
    occ = analyze(sc, Tuple(idx))
    if     sc[idx] == 1 (occ >= tol) ? 2 : 1  # seat was occupied
    elseif sc[idx] == 2 (occ == 0)   ? 1 : 2  # seat was empty
    elseif sc[idx] == 3 3                     # floor
    end
  end
end

function find_fixpoint(sc, analyze, tol)
  sc_before = zeros(Int, size(sc))
  while !all(sc .== sc_before)
    sc_before = sc
    sc = evolve_seat_config(sc, analyze, tol)
  end
  sc
end

function solve21(file)
  sc = parse_seat_config(file)
  sc_fix = find_fixpoint(sc, analyze_seat, 4)
  count(isequal(1), sc_fix)
end

@assert solve21("data/day11-test.txt") == 37
@assert solve21("data/day11.txt") == 2481

ray(size, (dx, dy)) = map(0:div(size[1]-1, dy)) do i
  CartesianIndex(1 + i*dy, 1 + (i*dx % size[2]))
end

function occupied_along_ray(sc, pos, dir)
  pos = pos .+ dir
  while all((1,1) .<= pos .<= size(sc))
    isequal(sc[pos...], 1) && return true
    isequal(sc[pos...], 2) && return false
    pos = pos .+ dir
  end
  false
end

function analyze_seat_ray(sc, pos)
  dirs = [(i,j) for i in -1:1, j in -1:1 if (i,j) != (0,0)]
  sum(dir -> occupied_along_ray(sc, pos, dir), dirs)
end

function solve22(file)
  sc = parse_seat_config(file)
  sc_fix = find_fixpoint(sc, analyze_seat_ray, 5)
  count(isequal(1), sc_fix)
end

@assert solve22("data/day11-test.txt") == 26
@assert solve22("data/day11.txt") == 2227


# Day 12

parse_navi_actions(file) = map(readlines(file)) do line
  line[1], parse(Int, line[2:end])
end

function discrete_rot(n, d)
  c = round.(Int, cos(n * pi / 180))
  s = round.(Int, sin(n * pi / 180))
  (c * d[1] - s * d[2], c * d[2] + s * d[1])
end

function apply_navi_actions(actions, state)

  update_state = Dict(
      'N' => (n, x, d) -> (x .+ (0,  n), d)
    , 'S' => (n, x, d) -> (x .+ (0, -n), d)
    , 'E' => (n, x, d) -> (x .+ (n,  0), d)
    , 'W' => (n, x, d) -> (x .+ (-n, 0), d)
    , 'L' => (n, x, d) -> (x, discrete_rot(n, d))
    , 'R' => (n, x, d) -> (x, discrete_rot(.-n, d))
    , 'F' => (n, x, d) -> (x .+ n .* d, d))

  foldl(actions, init=state) do state, action
    update_state[action[1]](action[2], state...)
  end

end

function solve23(file)
  actions = parse_navi_actions(file)
  pos, dir = apply_navi_actions(actions, ((0,0), (1, 0)))
  sum(abs, pos)
end

@assert solve23("data/day12-test.txt") == 25
@assert solve23("data/day12.txt") == 882

function apply_navi_actions_waypoint(actions, state)

  update_state = Dict(
      'N' => (n, x, y) -> (x, y .+ (0,  n))
    , 'S' => (n, x, y) -> (x, y .+ (0, -n))
    , 'E' => (n, x, y) -> (x, y .+ (n,  0))
    , 'W' => (n, x, y) -> (x, y .+ (-n, 0))
    , 'L' => (n, x, y) -> (x, discrete_rot(n, y))
    , 'R' => (n, x, y) -> (x, discrete_rot(.-n, y))
    , 'F' => (n, x, y) -> ((x .+ n .* y, y)) )

  foldl(actions, init=state) do state, action
    update_state[action[1]](action[2], state...)
  end

end

function solve24(file)
  actions = parse_navi_actions(file)
  pos, dir = apply_navi_actions_waypoint(actions, ((0,0), (10, 1)))
  sum(abs, pos)
end

@assert solve24("data/day12-test.txt") == 286
@assert solve24("data/day12.txt") == 28885


# Benchmark

using Printf

function benchmark(nmax)
  total = sum(1:nmax) do n
    path  = @sprintf("data/day%02d.txt", n)
    task1 = @sprintf("solve%02d", 2n-1) |> Symbol
    task2 = @sprintf("solve%02d", 2n)   |> Symbol
    time1 = @elapsed Expr(:call, task1, path) |> eval
    time2 = @elapsed Expr(:call, task2, path) |> eval
    @printf "day %02d: %.4f | %.4f\n" n time1 time2
    time1 + time2
  end
  @printf "----\ntotal: %.4f" total
end



