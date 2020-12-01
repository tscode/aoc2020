
using DelimitedFiles

function solve01()
  values = readdlm("day01.txt", Int)
  for x in values, y in values
    if x + y == 2020 && x <= y
      println("$x * $y = $(x*y)")
    end
  end
end

function solve02()
  values = readdlm("day01.txt", Int)
  for x in values, y in values, z in values
    if x + y + z == 2020 && x <= y <= z
      println("$x * $y * $z = $(x*y*z)")
    end
  end
end

