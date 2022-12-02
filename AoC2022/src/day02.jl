module day02

using InlineTest
using Match
const TEST_STRING = """A Y
B X
C Z"""


@testset "day02" begin
  @test solve(IOBuffer(TEST_STRING)) == (
    15,
    12
  )
end

@enum Moves Rock=1 Paper=2 Sissors=3

function win_score(x, y)
  val = 0
  if x == y
    val = 1
  elseif (Int(y) - Int(x) == 1) || (Int(x) - Int(y) == 2)
    val = 2
  end
  val * 3
end

function parse_move(move)
  @match move begin
    "A" => Rock
    "B" => Paper
    "C" => Sissors
    "X" => Rock
    "Y" => Paper
    "Z" => Sissors
  end
end

function score(moves)
  win_score(moves...) + Int(moves[2])
end


function load(file)
  parse(x) = parse_move.(split(x))
  parse.(readlines(file))
end


function problem1(A)
  sum(score.(A))
end

const beats = Dict(Rock=>Paper, Paper=>Sissors, Sissors=>Rock)
const ties = Dict(Rock=>Rock, Paper=>Paper, Sissors=>Sissors)
const loses = Dict(Rock=>Sissors, Paper=>Rock, Sissors=>Paper)
const predict_moves = Dict(Rock=>loses, Paper=>ties, Sissors=>beats)

function predict_move(move)
  predict_moves[move[2]][move[1]]
end

function problem2(A)
  B = deepcopy(A)
  for i=1:length(B)
    B[i][2] = predict_move(B[i])
  end
  sum(score.(B))
end

function solve(io::IO)
  A = load(io)
  (
    problem1(A), 
    problem2(A)
  )
end

end