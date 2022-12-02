module day01

using .InlineTest
const TEST_STRING = """1000
2000
3000

4000

5000
6000

7000
8000
9000

10000"""


@testset "day01" begin
  @test solve(IOBuffer(TEST_STRING)) == (24000, 45000)
end

Elf = Array{Int64, 1}

function load(file)
  lines = readlines(file)
  elves = Array{Elf, 1}()
  push!(elves, Elf())
  for i in 1:length(lines)
    if lines[i] == ""
      push!(elves, Elf())
    else
      push!(last(elves), parse(Int64, lines[i]))
    end
  end
  elves
end

function problem1(A)
  maximum(sum.(A))
end

function problem2(A)
  sum(sort(sum.(A), rev=true)[1:3])
end

function solve(io::IO)
  A = load(io)
  problem1(A), problem2(A)
end

end