
# Day 1

function solve01()
  values = parse.(Int, readlines("day01.txt"))
  for x in values, y in values
    if x + y == 2020 && x <= y
      println("$x * $y = $(x*y)")
    end
  end
end

function solve02()
  values = parse.(Int, readlines("day01.txt"))
  for x in values, y in values, z in values
    if x + y + z == 2020 && x <= y <= z
      println("$x * $y * $z = $(x*y*z)")
    end
  end
end

# Day 2

function solve03()
  println("Solve task 1 of day 2")
  lines = readlines("day02.txt")
  pat = r"^([0-9]+)-([0-9]+) ([a-z]): ([a-z]+)$"
  valid = filter(lines) do line
    m = match(pat, line)
    if isnothing(m)
      println("Error: did not understand entry '$line'")
      return false
    end
    min, max = parse.(Int, m.captures[1:2])
    letter = m.captures[3][1]
    pwd = m.captures[4]
    min <= count(isequal(letter), pwd) <= max
  end
  println("Answer: $(length(valid)) of $(length(lines)) passwords are valid")
end

function solve04()
  println("Solve task 2 of day 2")
  lines = readlines("day02.txt")
  pat = r"^([0-9]+)-([0-9]+) ([a-z]): ([a-z]+)$"
  valid = filter(lines) do line
    m = match(pat, line)
    if isnothing(m)
      println("Error: did not understand entry '$line'")
      return false
    end
    min, max = parse.(Int, m.captures[1:2])
    letter = m.captures[3][1]
    pwd = m.captures[4]
    count(isequal(letter),  pwd[[min, max]]) == 1
  end
  println("Answer: $(length(valid)) of $(length(lines)) passwords are valid")
end


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

@assert solve05("day03-test.txt") == 7
@assert solve05("day03.txt") == 148

function solve06(file)
  landscape = parse_forest(file)
  slopes = [(1,1), (3,1), (5,1), (7,1), (1,2)]
  trees = map(slopes) do slope
    indices = straight_path(size(landscape), slope)
    sum(landscape[indices])
  end
  prod(trees)
end

@assert solve06("day03-test.txt") == 336
@assert solve06("day03.txt") == 727923200


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

@assert solve07("day04-test.txt") == 2
@assert solve07("day04.txt") == 260

function solve08(file)
  passports = parse_passports(file)
  count(p -> check_keys(p) && check_values(p), passports)
end

@assert solve08("day04.txt") == 153

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

@assert solve09("day05.txt") == 813

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

@assert solve10("day05.txt") == 612


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

@assert solve11("day06-test.txt") == 11
@assert solve11("day06.txt") == 6930

function solve12(file)
  data = map(q -> intersect(q...), parse_questionairs(file))
  sum(length, data)
end

@assert solve12("day06-test.txt") == 6
@assert solve12("day06.txt") == 3585


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

function nparent_bags(rbc, color)
  parents = rbc[color]
  union(parents, map(x -> parent_bags(rbc, x), parents)...) |> length
end

function solve13(file)
  rbc = parse_bagsicon(file) |> reverse_bagsicon
  nparent_bags(rbc, "shiny gold")
end

@assert solve13("day07-test.txt") == 4
@assert solve13("day07.txt") == 254

function nchild_bags(bc, color)
  cs = bc[color]
  isempty(cs) ? 0 : sum(c -> c[1] + c[1] * nchild_bags(bc, c[2]), cs)
end

function solve14(file)
  bc = parse_bagsicon(file)
  nchild_bags(bc, "shiny gold")
end

@assert solve14("day07-test.txt") == 32
@assert solve14("day07-test2.txt") == 126
@assert solve14("day07.txt") == 6006

