
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

boolean_masks(k) = map( 1:2^k ) do n # all boolean masks of length k
  parse.(Bool, bitstring(n-1)[end-k+1:end] |> collect)
end

function count_arrangements(sublist)
  k = length(sublist) - 2
  masks = boolean_masks(k)
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


# Day 13

function parse_schedule(file)
  lines = readlines(file)
  bus_ids = parse.(Int, split(lines[2], r"x?,x?", keepempty=false))
  parse(Int, lines[1]), bus_ids
end


function solve25(file)
  time, ids = parse_schedule(file)
  val, i = findmin(ids .- ((time - 1) .% ids) .- 1)
  ids[i] * val
end

@assert solve25("data/day13-test.txt") == 295
@assert solve25("data/day13.txt") == 333


function parse_schedule_contest(file)
  n, a = Int[], Int[]
  for (i, v) in split(readlines(file)[2], ",") |> enumerate
    if !isequal(v, "x")
      push!(n, parse(Int, v))
      push!(a, -(i-1))
    end
  end
  n, a
end

# Smallest positive solution x to system 
#   x = a_i + x_i * n_i 
# given n_i > 1 coprime and a_i integers.
function solve_chinese_remainder(n, a)
  m = prod(n)
  s = mapreduce(+, n, a) do ni, ai
    ai * div(m, ni) * invmod(div(m, ni), ni)
  end
  (s % m) + (s < 0) * m
end

function solve26(file)
  n, a = parse_schedule_contest(file)
  solve_chinese_remainder(n, a)
end

@assert solve26("data/day13-test.txt") == 1068781
@assert solve26("data/day13.txt") == 690123192779524


# Day 14

tobits(u :: Int) = digits(u, base = 2, pad = 36)
ofbits(a :: Vector{Int64}) = sum(i -> a[i] * 2^(i-1), 1:length(a))

function parse_docking_program(file)
  mdict = Dict('X' => -1, '1' => 1, '0' => 0)
  parse_mask(str) = Int[mdict[s] for s in collect(str)] |> reverse
  map(readlines(file)) do line
    m = match(r"^mask = ([X|1|0]+)$", line)
    if !isnothing(m)
      :mask, parse_mask(m.captures[1])
    else
      m = match(r"^mem\[([0-9]+)\] = ([0-9]+)$", line)
      :mem, parse.(Int, m.captures)
    end
  end
end

function execute_docking_program_v1(dp)
  mbit(a, m) = isequal(m, -1) ? a : m
  init = Dict(), nothing
  foldl(dp; init) do (mem, mask), (op, v)
    op == :mask && (mask = v)
    op == :mem  && (mem[v[1]] = mbit.(v[2] |> tobits, mask) |> ofbits)
    (mem, mask)
  end |> first
end

function solve27(file)
  dp = parse_docking_program(file)
  mem = execute_docking_program_v1(dp)
  sum(values(mem))
end

@assert solve27("data/day14-test.txt") == 165
@assert solve27("data/day14.txt") == 13727901897109

function decode_memory_addresses(val, mask)
  decode_bit(v, m) = isequal(m, 0) ? v : m
  dval = decode_bit.(tobits(val), mask)
  floating = findall(isequal(-1), dval)
  map(boolean_masks(length(floating))) do bmask
    dval = copy(dval)
    dval[floating] .= bmask
    ofbits(dval)
  end
end

function execute_docking_program_v2(dp)
  init = Dict(), nothing
  foldl(dp; init) do (mem, mask), (op, v)
    if op == :mask
      mask = v
    else
      indices = decode_memory_addresses(v[1], mask)
      for i in indices mem[i] = v[2] end
    end
    mem, mask
  end |> first
end

function solve28(file)
  dp = parse_docking_program(file)
  mem = execute_docking_program_v2(dp)
  sum(values(mem))
end

@assert solve28("data/day14-test2.txt") == 208
@assert solve28("data/day14.txt") == 5579916171823


# Day 15

function memory_game(start, n)
  k = length(start)
  spoken = Dict{Int, Int}(s => i for (i,s) in enumerate(start[1:end-1]))
  prev = start[end]
  for i in (k+1):n
    age = haskey(spoken, prev) ? (i-1) - spoken[prev] : 0
    spoken[prev] = (i-1)
    prev = age
  end
  prev
end

solve29(input) = memory_game(input, 2020)

@assert solve29([0, 3, 6]) == 436
@assert solve29([1, 3, 2]) == 1
@assert solve29([2, 1, 3]) == 10
@assert solve29([1, 2, 3]) == 27
@assert solve29([2, 3, 1]) == 78
@assert solve29([3, 2, 1]) == 438
@assert solve29([3, 1, 2]) == 1836

@assert solve29([13,0,10,12,1,5,8]) == 260

solve30(input) = memory_game(input, 30000000)

# This takes too long...
#@assert solve30([0, 3, 6]) == 175594
#@assert solve30([13, 0, 10, 12, 1, 5, 8]) == 950


# Day 16

function parse_ticket_input(file)
  reg = r"^([ a-z]+): ([0-9]+)-([0-9]+) or ([0-9]+)-([0-9]+)$"
  rstr, tstr, nstr = split(read(file, String), "\n\n")
  rules = map(split(rstr, "\n")) do rule
    m = match(reg, rule)
    a, b, c, d = parse.(Int, m.captures[2:end])
    string(m.captures[1]) => ((a, b), (c, d))
  end
  ticket = parse.(Int, split(split(tstr, "\n")[2], ","))
  nearby = map(split(nstr, "\n", keepempty=false)[2:end]) do t
    parse.(Int, split(t, ",")) 
  end
  (rules = Dict(rules), ticket = ticket, nearby = nearby)
end

function valid_field_set(rules)
  regions = map(values(rules)) do (r1, r2)
    Set([collect(r1[1]:r1[2]); collect(r2[1]:r2[2])])
  end
  union(regions...)
end

function scanning_error_rate(rules, tickets)
  set = valid_field_set(rules)
  sum(tickets) do ticket
    sum(t -> !(t in set) * t,  ticket)
  end
end

function solve31(file)
  ti = parse_ticket_input(file)
  scanning_error_rate(ti.rules, ti.nearby)
end

@assert solve31("data/day16-test.txt") == 71
@assert solve31("data/day16.txt") == 21081

function filter_rules(rules, tickets)
  set = valid_field_set(rules)
  filter(tickets) do ticket
    all(t -> t in set, ticket)
  end
end

function index_options(rule, tickets)
  matches(t, (r1, r2)) = (r1[1] <= t <= r1[2] || r2[1] <= t <= r2[2])
  findall(1:length(tickets[1])) do i
    all(t -> matches(t[i], rule), tickets)
  end
end

function possible_indices(rules, tickets)
  classes = Dict{String, Vector{Int}}()
  for (name, rule) in rules
    classes[name] = index_options(rule, tickets)
  end
  classes
end

function resolve_indices(indices)
  given = Set{Int}()
  map(1:20) do len
    name = findfirst(val -> length(val) == len, indices)
    idx = setdiff(indices[name], given)
    @assert length(idx) == 1
    push!(given, idx[1])
    name => idx[1]
  end |> Dict
end

function solve32(file)
  ti = parse_ticket_input(file)
  tickets = [filter_rules(ti.rules, ti.nearby); [ti.ticket]]
  indices = possible_indices(ti.rules, tickets) |> resolve_indices
  prod(ti.ticket[v] for (k,v) in indices if occursin("departure", k))
end

@assert solve32("data/day16.txt") == 314360510573


# Day 17

function parse_conway_cubes(file, extra_dims = (1,))
  lookup = Dict('#' => true, '.' => false)
  cubes = mapreduce(vcat, readlines(file)) do line
    map(c -> lookup[c], collect(line))'
  end
  reshape(cubes, size(cubes)..., extra_dims...)
end

function inflate_conway_space(cubes)
  space = zeros(Bool, (size(cubes) .+ 2))
  low = ntuple(_ -> 2, length(size(cubes))) |> CartesianIndex
  upp = size(cubes) .+ 1                    |> CartesianIndex
  space[low:upp] .= cubes
  space
end

decrease_index(i) = (i-1) > 0 ? (i-1) : 1
increase_index(i, m) = (i+1) > m ? m : (i+1)

function apply_conway_rule(state, active)
  if state
    2 <= active <= 3 ? true : false
  else
    active == 3 ? true : false
  end
end

function evolve_conway_cubes(cubes)
  cubes = inflate_conway_space(cubes)
  map(CartesianIndices(cubes)) do idx
    low = decrease_index.(Tuple(idx))              |> CartesianIndex
    upp = increase_index.(Tuple(idx), size(cubes)) |> CartesianIndex
    active = sum(cubes[low:upp]) - cubes[idx]
    apply_conway_rule(cubes[idx], active) 
  end
end

function solve33(file)
  cubes = parse_conway_cubes(file) # 3d
  for i in 1:6 cubes = evolve_conway_cubes(cubes) end
  sum(cubes)
end

@assert solve33("data/day17-test.txt") == 112
@assert solve33("data/day17.txt") == 291

function solve34(file)
  cubes = parse_conway_cubes(file, (1,1)) # 4d
  for i in 1:6 cubes = evolve_conway_cubes(cubes) end
  sum(cubes)
end

@assert solve34("data/day17-test.txt") == 848
@assert solve34("data/day17.txt") == 1524

# Day 18

# Writing a parser in julia is no fun.
# However, julia has a parser that supports all demanded features :)
# Let's use meta-programming to hack the challenge!

function replace_operation!(ex :: Expr, pair :: Pair{Symbol, Symbol})
  for (i, arg) in enumerate(ex.args)
    if     arg == pair[1] ex.args[i] = pair[2]
    elseif arg isa Expr   replace_operation!(arg, pair)
    end
  end
  ex
end

function eval_term(str, aux = :/)
  ex = Meta.parse(replace(str, "+" => string(aux))) # hack the precedence ...
  eval(replace_operation!(ex, aux => :+)) # ... and restore the meaning after parsing :)
end

solve35(file) = sum(eval_term, readlines(file))

@assert solve35("data/day18-test.txt") == (26 + 437 + 12240 + 13632)
@assert solve35("data/day18.txt") == 45283905029161

solve36(file) = sum(l -> eval_term(l, :^), readlines(file))

@assert solve36("data/day18-test.txt") == (46 + 1445 + 669060 + 23340)
@assert solve36("data/day18.txt") == 216975281211165


# Day 19

function parse_message_input(file)
  rules, msgs = split(read(file, String), "\n\n")
  rules = map(split(rules, "\n")) do line
    id, rule = split(line, ": ")
    parse(Int, id) => map(split(rule, "|")) do subrule
      ms = eachmatch(r"[0-9]+", subrule)
      if isempty(ms)
        match(r"a|b", subrule).match[1]
      else
        map(m -> parse(Int, m.match), ms)
      end
    end
  end
  Dict(rules), split(msgs, "\n")
end


function consume(rules, n, input)
  rule = rules[n]
  if isempty(input)
    []
  elseif rule[1] isa Char # Assuming here that no rule is "a" | "b"
    rule[1] == input[1] ? [input[2:end]] : []
  else
    # Collecting all possible residues if rule consumes input
    mapreduce(vcat, rule) do subrule # | is 'or', so we can combine residues
      reduce(subrule, init=[input]) do residues, r
        isempty(residues) && return []
        mapreduce(res -> consume(rules, r, res), vcat, residues)
      end
    end |> unique
  end
end

function solve37(file)
  rules, msgs = parse_message_input(file)
  sum("" in consume(rules, 0, msg) for msg in msgs)
end

@assert solve37("data/day19-test.txt") == 2
@assert solve37("data/day19.txt") == 216

function fix_rules!(rules)
  rules[8]  = [[42], [42, 8]]
  rules[11] = [[42, 31], [42, 11, 31]]
end

function solve38(file)
  rules, msgs = parse_message_input(file)
  fix_rules!(rules)
  sum("" in consume(rules, 0, msg) for msg in msgs)
end

@assert solve38("data/day19-test2.txt") == 12
@assert solve38("data/day19.txt") == 400


# Day 20

const l1_directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]

function parse_images(file)
  dict = Dict('#' => true, '.' => false)
  tiles = map(split(read(file, String), "\n\n")) do str
    lines = split(str, "\n", keepempty=false)
    id = parse(Int, match(r"[0-9]+", lines[1]).match)
    id => mapreduce(vcat, lines[2:end]) do row
      map(c -> dict[c], collect(row))'
    end
  end |> Dict
end

function image_edge(img, dir)
  if     dir == (0,  1) i, j = 1:size(img, 1), size(img, 2)
  elseif dir == (0, -1) i, j = 1:size(img, 1), 1
  elseif dir == (1,  0) i, j = size(img, 1), 1:size(img, 2)
  else                  i, j = 1, 1:size(img, 2)
  end
  img[i,j]
end

edge_hashes(img) = map(l1_directions) do dir
  hash(image_edge(img, dir))
end

function orbit_dihedral8(img)
  hflip(img) = reverse(img, dims = 1)
  vflip(img) = reverse(img, dims = 2)
  trans(img) = transpose(img) |> collect
  [ img                              # a b; c d
  , img |> vflip                     # b a; d c
  , img |> hflip                     # c d; a b
  , img |> hflip |> vflip            # d c; b a
  , img |> trans                     # a c; b d
  , img |> trans |> hflip            # b d; a c
  , img |> trans |> vflip            # c a; d b
  , img |> trans |> vflip |> hflip ] # d b; c a
end

orbit_hashed(image) = map(orbit_dihedral8(image)) do img
  img, edge_hashes(img)
end

function match_edges_hash((img, hash), orbit)
  for (i, dir) in enumerate(l1_directions)
    idx = findfirst(orbit) do (c, h)
      hit = (hash[i] == h[(i+1) % 4 + 1]) # depends on the ordering in l1_directions...
      # short-circuiting causes a considerable performance boost
      hit && all(image_edge(img, dir) .== image_edge(c, .- dir))
    end
    !isnothing(idx) && return (dir, orbit[idx][1])
  end
end

function reassamble_step!(imgs, orbits, grid)
  # use a set for fast lookup of images that are already placed in the grid
  placed = Set(grid) 
  # try to glue not-yet-placed images to already-placed images
  for pos in CartesianIndices(grid)
    # if there is no image at the position yet, we can continue
    id = grid[pos]
    id <= 0 && continue
    for (cid, candidate) in imgs
      # if the image cid is already placed, continue
      cid in placed && continue 
      # check for matching edges in an (unplaced) candidate image
      r = match_edges_hash(orbits[id][1], orbits[cid])
      # in case of a match, update everything
      if !isnothing(r)
        cpos = CartesianIndex(Tuple(pos) .+ r[1])
        grid[cpos] = cid
        imgs[cid] = r[2] 
        orbits[cid] = orbit_hashed(r[2])
        push!(placed, cid)
      end
    end
  end
end

function reassamble_image!(imgs)
  # select an initial image
  id = first(keys(imgs))
  # place this image at the center of a (sufficiently large) grid
  l = length(imgs)
  grid = zeros(Int, 2l + 1, 2l + 1)
  grid[l + 1, l + 1] = id
  # cache rotated images as well as hashes for the edges
  orbits = Dict(id => orbit_hashed(img) for (id, img) in imgs)
  # iterate over all placed images and try to place new images next to them.
  # After some steps, we should find a fixpoint in this iteration.
  while sum(grid .> 0) < length(imgs)
    reassamble_step!(imgs, orbits, grid)
  end
  # shrink the grid to occupied positions only
  i, j = (sum(grid, dims = d) .> 0 for d in (2, 1))
  grid[dropdims(i, dims = 2), dropdims(j, dims = 1)]
end

function solve39(file)
  imgs = parse_images(file)
  grid = reassamble_image!(imgs)
  grid[1,1] * grid[1,end] * grid[end, 1] * grid[end, end]
end


@assert solve39("data/day20-test.txt") == 20899048083289
@assert solve39("data/day20.txt") == 8425574315321


function sea_monster()
  Bool[ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0
      ; 1 0 0 0 0 1 1 0 0 0 0 1 1 0 0 0 0 1 1 1
      ; 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 0 ] 
end

function construct_image(imgs, grid)
  s = size(first(imgs)[2]) .- 2
  image = zeros(Bool, size(grid) .* s)
  for i in 1:size(grid, 1), j in 1:size(grid, 2)
    irange = ((i-1)*s[1]+1):(i*s[1])
    jrange = ((j-1)*s[2]+1):(j*s[2])
    image[irange, jrange] .= imgs[grid[i,j]][2:end-1, 2:end-1]
  end
  image
end

function detect_monsters(image, monster)
  match_pixel(i, m) = !m ? true : i
  si = size(image)
  sm = size(monster)
  coords = []
  for i = 1:(si[1] - sm[1] + 1), j = 1:(si[2] - sm[2] + 1)
    if all(match_pixel.(image[i:i+sm[1]-1, j:j+sm[2]-1], monster))
      push!(coords, (i, j))
    end
  end
  coords
end

function sea_monster_correction(habitat, monster)
  count(CartesianIndices(habitat)) do idx
    monster[idx] && habitat[idx] 
  end
end

function solve40(file)
  imgs = parse_images(file)
  grid = reassamble_image!(imgs)
  image = construct_image(imgs, grid)
  monster = sea_monster()
  for img in orbit_dihedral8(image)
    coords = detect_monsters(img, monster)
    if !isempty(coords)
      nmonster = sum(coords) do (i, j)
        habitat = img[i:i+size(monster, 1)-1, j:j+size(monster, 2)-1]
        sea_monster_correction(habitat, monster)
      end
      return sum(image) - nmonster
    end
  end
end

@assert solve40("data/day20-test.txt") == 273
@assert solve40("data/day20.txt") == 1841

# Day 21

function parse_recipes(file)
  map(readlines(file)) do line
    ig, al = match(r"^([a-z ]+) \(contains ([a-z ,]+)\)$", line).captures
    String.(split(ig, " ")), String.(split(al, ", "))
  end
end

function allergene_dict(recipes)
  amap = map(recipes) do r
    Dict(a => Set(r[1]) for a in r[2])
  end
  merge(intersect, amap...)
end

all_ingredients(recipes) = union(map(r -> Set(first(r)), recipes)...)

function solve41(file)
  recipes = parse_recipes(file)
  ing = union(values(allergene_dict(recipes))...)
  sum(setdiff(all_ingredients(recipes), ing)) do ingredient
    count(r -> ingredient in r[1], recipes)
  end
end

@assert solve41("data/day21-test.txt") == 5
@assert solve41("data/day21.txt") == 2262

function reverse_allergene_dict(allergenes)
  ings = union(values(allergenes)...)
  map(collect(ings)) do ing
    ing => filter(a -> ing in allergenes[a], keys(allergenes))
  end |> Dict
end

function resolve_ingredients_step!(resolved, allergenes)
  rev = reverse_allergene_dict(allergenes)
  for (a, ing) in allergenes
    if length(ing) == 1 && !(a in resolved)
      i = first(ing)
      for al in rev[i]
        a != al && setdiff!(allergenes[al], ing)
      end
      push!(resolved, ing)
    end
  end
end

function solve42(file)
  recipes = parse_recipes(file)
  allergenes = allergene_dict(recipes)
  resolved = Set()
  while length(resolved) < length(allergenes)
    resolve_ingredients_step!(resolved, allergenes)
  end
  ings = map(x -> first(x[2]), sort(collect(allergenes), by = first))
  join(ings, ",")
end

@assert solve42("data/day21-test.txt") == "mxmxvkd,sqjhc,fvjkl"
@assert solve42("data/day21.txt") == "cxsvdm,glf,rsbxb,xbnmzr,txdmlzd,vlblq,mtnh,mptbpz"


# Day 22

function parse_decks(file)
  map(split(read(file, String), "\n\n")) do p
    parse.(Int, split(p, "\n", keepempty = false)[2:end])
  end
end

function play_combat_round!(deck1, deck2)
  c1, c2 = popfirst!(deck1), popfirst!(deck2)
  c1 > c2 ? push!(deck1, c1, c2) : push!(deck2, c2, c1)
end

function play_combat(deck1, deck2)
  while true
    play_combat_round!(deck1, deck2)
    isempty(deck1) && (return deck2)
    isempty(deck2) && (return deck1)
  end
end

function solve43(file)
  deck1, deck2 = parse_decks(file)
  deck = play_combat(deck1, deck2)
  sum(deck .* (length(deck):-1:1))
end

take_snapshot(d1, d2) = hash((d1, d2))

function play_recursive_combat(deck1, deck2)
  d = (d1, d2) = copy(deck1), copy(deck2)
  snapshots = Set{UInt64}()
  n = 0
  while true
    # declare player 1 as winner if constellation is known
    n += 1
    s = take_snapshot(d1, d2) 
    s in snapshots && (return (1, (deck1, deck2)))
    # save snapshot of current constellation
    push!(snapshots, s)
    # draw cards
    c1, c2 = popfirst!(d1), popfirst!(d2)
    # if both players have enough cards, a new round is played
    if c1 <= length(d1) && c2 <= length(d2)
      winner = play_recursive_combat(d1[1:c1], d2[1:c2])[1]
    # else the player with higher number wins
    else
      winner = c1 > c2 ? 1 : 2
    end
    winner == 1 ? push!(d1, c1, c2) : push!(d2, c2, c1)

    isempty(d1) && (return (2, (d1, d2)))
    isempty(d2) && (return (1, (d1, d2)))
  end
end

function solve44(file)
  deck1, deck2 = parse_decks(file)
  winner, decks = play_recursive_combat(deck1, deck2)
  sum(decks[winner] .* (length(decks[winner]):-1:1))
end

@assert solve44("data/day22-test.txt") == 291
@assert solve44("data/day22.txt") == 32054


# Day 23

cindex(i, n) = ((i-1) % n) + 1

function crab_move!(cups, current)
  n = length(cups)
  take1 = cups[current]
  take2 = cups[take1]
  take3 = cups[take2]
  curr = cups[take3]
  dest = cindex(current - 1 + n, n)
  while dest == take1 || dest == take2 || dest == take3
    dest = cindex(dest - 1 + n, n)
  end
  cups[current] = curr
  cups[take3] = cups[dest]
  cups[dest] = take1
  curr
end

function linear_to_labels(input)
  n = length(input)
  cups = zeros(Int, n)
  for i in 1:n cups[input[i]] = input[cindex(i+1, n)] end
  cups
end

function labels_to_linear(cups)
  c, n = 1, length(cups)
  input = zeros(Int, n)
  for i in 1:n
    input[i] = c
    c = cups[c]
  end
  input
end

function solve45(input, steps = 100)
  input = parse.(Int, collect(input))
  cups = linear_to_labels(input)
  current = input[1]
  for _ in 1:steps
    current = crab_move!(cups, current)
  end
  labels_to_linear(cups)[2:end] |> join
end

@assert solve45("389125467") == "67384529"
@assert solve45("784235916") == "53248976"

function solve46(input, steps = 10000000)
  input = [parse.(Int, collect(input)); length(input)+1:1000000]
  current = input[1]
  cups = linear_to_labels(input)
  for _ in 1:steps
    current = crab_move!(cups, current)
  end
  a = cups[1]
  b = cups[a]
  a * b
end

@assert solve46("389125467") == 149245887792
@assert solve46("784235916") == 418819514477

# Benchmark

using Printf

function benchmark(nmax)
  total = sum(1:nmax) do n
    n == 15 && (return 0.)  # On day 15, we used no file input
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

