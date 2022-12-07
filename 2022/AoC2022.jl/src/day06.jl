module day06

using InlineTest
using DataStructures
using BenchmarkTools

@testset "day06" begin
  @test problem1(load(IOBuffer("""bvwbjplbgvbhsrlpgdmjqwftvncz"""))) == 5
  @test problem1(load(IOBuffer("""nppdvjthqldpwncqszvftbrmjlhg"""))) == 6
  @test problem1(load(IOBuffer("""nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"""))) == 10
  @test problem1(load(IOBuffer("""zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"""))) == 11
  @test problem2(load(IOBuffer("""mjqjpqmgbljsphdztnvjfqwrcgsmlb"""))) == 19
  @test problem2(load(IOBuffer("""bvwbjplbgvbhsrlpgdmjqwftvncz"""))) == 23
  @test problem2(load(IOBuffer("""nppdvjthqldpwncqszvftbrmjlhg"""))) == 23
  @test problem2(load(IOBuffer("""nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"""))) == 29
  @test problem2(load(IOBuffer("""zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"""))) == 26
end

function load(file)
  T = Int32
  line = readlines(file)[1]
  T.(collect(line)) .- (T('a') - T(1))
end

function find_unique_start(A::Vector{T}, len) where {T}
  tmp = zeros(T, 26)
  for i in 1:len-1
    tmp[A[i]] += T(1)
  end
  s = sum(tmp .> T(0))
  for i in len:length(A)
    curr = A[i]
    tmp[curr] += T(1)
    s = tmp[curr] == T(1) ? s + T(1) : s
    if s == len
      return i
    end
    prev = A[i-len+1]
    tmp[prev] -= T(1)
    s = tmp[prev] == T(0) ? s - T(1) : s
  end
  return -1
end

function problem1(A)
  find_unique_start(A, 4)
end

function problem2(A)
  find_unique_start(A, 14)
end

function solve(io::IO)
  A = load(io)
  @btime problem2($A)
  (
    problem1(A), 
    problem2(A)
  )
end

end