module day03

using InlineTest
const TEST_STRING = """vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw"""


@testset "day02" begin
  @test solve(IOBuffer(TEST_STRING)) == (
    157,
    70
  )
end

struct Rucksack
  N::Int64
  items::Vector{Char}
end

Rucksack(line::String) = Rucksack(length(line), collect.(line))

priority(char) = Int(char) - (isuppercase(char) ? Int('A') - 27 : Int('a') - 1)

load(file) = Rucksack.(readlines(file))

overlap(x::Rucksack) = [c for c in x.items[1:x.N÷2] if c in x.items[x.N÷2+1:x.N]][1]
overlap(x::Vector{Rucksack}) = [c for c in x[1].items if c in x[2].items && c in x[3].items][1]

problem1(A) = sum(priority.(overlap.(A)))

problem2(A) = sum(priority.(overlap.([A[i:i+2] for i in 1:3:length(A)])))  

function solve(io::IO)
  A = load(io)
  (
    problem1(A), 
    problem2(A)
  )
end

end