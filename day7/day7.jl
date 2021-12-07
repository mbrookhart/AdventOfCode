function load(file)
  parse.(Int64, split(readlines(file)[1], ","))
end

function problem1(A)
  m = maximum(A)
  least_fuel = length(A) * m
  for i in 0:m
    tmp = sum(abs.(A .- i))
    if tmp < least_fuel
      least_fuel = tmp
    end
  end
  least_fuel
end

function problem2(A)
  m = maximum(A)
  least_fuel = length(A) * m^2
  for i in 0:m
    tmp = 0
    for j in abs.(A .- i)
      for k in 1:j
        tmp += k
      end
    end
    if tmp < least_fuel
      least_fuel = tmp
    end
  end
  least_fuel
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  @assert problem1(A) == 37
  @assert problem2(A) == 168

  B = load("input.txt")
  println(problem1(B))
  println(problem2(B))
end
