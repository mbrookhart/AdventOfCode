module day06

using InlineTest
using DataStructures
using BenchmarkTools
using Profile

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
  line = readlines(file)[1]
  Int32.(collect(line)) .- (Int32('a') - 1)
end

function find_unique_start(A, len)
  tmp = zeros(Int32, 26)
  for i in len:length(A)
    for j in i-len+1:i
      tmp[A[j]] += 1
    end
    s = 0
    for j in 1:26
      s += min(tmp[j], 1)
    end
    if s == len
      return i
    end
    tmp .= 0
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
  @time problem2(A)
  Profile.init(delay = 2e-6)
  @profile problem2(A)

  Profile.print()

  (
    problem1(A), 
    problem2(A)
  )
end

end