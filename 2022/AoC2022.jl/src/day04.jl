module day04

using InlineTest
using Match
const TEST_STRING = """2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8"""


@testset "day04" begin
  @test solve(IOBuffer(TEST_STRING)) == (
    2,
    4
  )
end

function load(file)
  split_int(x) = parse.(Int64, split(x, "-"))
  split_lines(x) = split_int.(split(x, ","))
  split_lines.(readlines(file))
end

function entirely_overlap(v)
    a,b = v
    if a[1]>=b[1] && a[2] <= b[2]
        return true
    elseif b[1]>=a[1] && b[2]<=a[2]
        return true
    end
    return false
end

function partially_overlap(v)
    a,b = v
    if a[1] <= b[1]
        s = a
        l = b
    else
        s = b
        l = a
    end
    if s[2] < l[1]
        return false
    end
    return true
end

function problem1(A)
  sum(entirely_overlap.(A))
end

function problem2(A)
  sum(partially_overlap.(A))
end

function solve(io::IO)
  A = load(io)
  (
    problem1(A), 
    problem2(A)
  )
end

end