module day13

using InlineTest
using DataStructures
using Profile
using BenchmarkTools

@testset "day13" begin
  @test solve(open("../data/day13.test")) == (
    13,
    140
  )
end


function load(file)
  lines = readlines(file)
  [eval(Meta.parse(lines[i])) for i in 1:length(lines) if mod(i, 3) != 0]
end

function compare(left::Vector, right::Vector)
  correct = 1
  for i in 1:length(left)
    if i > length(right)
      return -1
    end
    tmp = compare(left[i], right[i])
    if tmp != 0
      return tmp
    end
  end
  if length(left) == length(right)
    return 0
  end
  correct
end  

compare(left::Int, right::Int) = sign(right - left)
compare(left::Vector, right::Int) = compare(left, [right])
compare(left::Int, right::Vector) = compare([left], right)

function problem1(A)
  sum([(i-1)÷2 + 1 for i in 1:2:length(A) if compare(A[i], A[i+1])>0])
end

less_than(x, y) = compare(x, y) > 0
equals(x,y) = compare(x,y) == 0

function problem2(A)
  B = deepcopy(A)
  push!(B, [[2]])
  push!(B, [[6]])
  sort!(B, lt=less_than)
  val = 1
  for i in 1:length(B)
    if (equals(B[i], [[2]]) || equals(B[i],[[6]]))
      val *= i
    end
  end
  val
end

function solve(io::IO)
  A = load(io)
  (
    problem1(A),
    problem2(A)
  )
end

end