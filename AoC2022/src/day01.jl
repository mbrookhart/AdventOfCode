module day01

using .InlineTest
using .Match
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

Elf = Vector{Int64}

function load(file)
  elves = Vector{Elf}()
  push!(elves, Elf())
  parse_line(line) = @match line begin
    "" => push!(elves, Elf())
    _ => push!(last(elves), parse(Int64, line))
  end
  parse_line.(readlines(file))
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