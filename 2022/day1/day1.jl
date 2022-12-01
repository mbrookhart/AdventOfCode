Elf = Array{Int64, 1}

function load(file)
  lines = readlines(file)
  println(parse.(Int64, lines))
  println(split(lines, ""))
  elves = Array{Elf, 1}()
  push!(elves, Elf())
  for i in 1:length(lines)
    if lines[i] == ""
      push!(elves, Elf())
    else
      push!(last(elves), parse(Int64, lines[i]))
    end
  end
  return elves
end

function problem1(A)
  maximum(sum.(A))
end

function problem2(A)
  totals = sum.(A)
  top = sort(totals, rev=true)[1:3]
  sum(top)
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  @assert problem1(A) == 24000
  @assert problem2(A) == 45000

  A = load("input.txt")
  println(problem1(A))
  println(problem2(A))
end
