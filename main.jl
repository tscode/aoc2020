
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
