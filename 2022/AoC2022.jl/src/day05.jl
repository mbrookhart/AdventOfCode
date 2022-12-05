module day05

using InlineTest
using DataStructures
const TEST_STRING = """    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2"""


@testset "day05" begin
  @test solve(IOBuffer(TEST_STRING)) == (
    "CMZ",
    "MCD"
  )
end

YardStack = Vector{Char}
Yard = Vector{YardStack}

struct Move 
  num::Int64
  start::Int64
  finish::Int64
end

function parse_move(line)
  values = split(line, " ")[2:2:end]
  Move(parse.(Int64, values)...)
end

function parse_stacks(lines)
  yard = Yard()
  N = length(lines[end])
  i = 2
  while (i < N)
    stack = YardStack()
    for j = length(lines) - 1:-1:1
      if lines[j][i] != ' '
        push!(stack, lines[j][i])
      end
    end
    push!(yard, stack)
    i+=4
  end
  yard
end

function load(file)
  lines = readlines(file)
  data_split = findall(x->x=="", lines)[1]
  yard = parse_stacks(lines[1:data_split-1])
  moves = parse_move.(lines[data_split + 1:end])
  yard, moves
end

function apply_move_9000!(yard, move)
  for i in 1:move.num
    tmp = pop!(yard[move.start])
    push!(yard[move.finish], tmp)
  end
end

function problem1(yard, moves)
  yard = deepcopy(yard)
  for move in moves
    apply_move_9000!(yard, move)
  end
  String([tmp[end] for tmp in yard])
end

function apply_move_9001!(yard, move)
  s = Stack{Char}()
  for i in 1:move.num
    push!(s, pop!(yard[move.start]))
  end
  while !isempty(s)
    push!(yard[move.finish], pop!(s))
  end
end

function problem2(yard, moves)
  yard = deepcopy(yard)
  for move in moves
    apply_move_9001!(yard, move)
  end
  String([tmp[end] for tmp in yard])
end

function solve(io::IO)
  yard, moves = load(io)
  (
    problem1(yard, moves), 
    problem2(yard, moves)
  )
end

end