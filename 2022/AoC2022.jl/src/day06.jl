module day06

using InlineTest
using DataStructures

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
  collect(line)
end

function find_unique_start(A, len)
  tmp = Queue{Char}()
  for i in 1:len
    enqueue!(tmp, A[i])
  end
  for i in len+1:length(A)
    if length(unique(tmp)) == len
      return i - 1
    else
      enqueue!(tmp, A[i]) 
      dequeue!(tmp)
    end
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
  (
    problem1(A), 
    problem2(A)
  )
end

end