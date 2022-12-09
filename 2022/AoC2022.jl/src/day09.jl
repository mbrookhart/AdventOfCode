module day09

using InlineTest
using Match
using BenchmarkTools
const TEST_STRING = """R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2
"""

const TEST_STRING2 = """R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20"""

struct Pos
  x::Int64
  y::Int64
end


@testset "day09" begin
  @test solve(IOBuffer(TEST_STRING)) == (
    13,
    1
  )
  @test problem2(load(IOBuffer(TEST_STRING2))) == 36
end


function load(file)
  split.(readlines(file))
end

function move_head(H, dir)
  @match dir begin
    "L" => Pos(H.x - 1, H.y    )
    "R" => Pos(H.x + 1, H.y    )
    "U" => Pos(H.x,     H.y + 1)
    "D" => Pos(H.x,     H.y - 1)
  end
end

function move_tail(H, T)
  if abs(H.x - T.x) > 1 || abs(H.y - T.y) > 1
    return Pos(T.x + sign(H.x - T.x), T.y + sign(H.y - T.y))
  end
  T
end


function simulate_moves(moves, rope_len)
  Ts = [[Pos(0,0)] for i in 1:rope_len]
  for move in moves
    for i in 1:parse(Int64, move[2])
      push!(Ts[1], move_head(Ts[1][end], move[1]))
      for i in 2:rope_len
        push!(Ts[i], move_tail(Ts[i-1][end], Ts[i][end]))
      end
    end
  end
  length(unique(Ts[rope_len]))
end

problem1(moves) = simulate_moves(moves, 2)
problem2(moves) = simulate_moves(moves, 10)

function solve(io::IO)
  A = load(io)
  (
    problem1(A), 
    problem2(A)
  )
end

end