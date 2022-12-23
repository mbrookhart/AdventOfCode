module day22

using InlineTest
using Match

@testset "day22" begin
  @test turn('>', 'R') == 'v'
  @test turn('>', 'L') == '^'
  @test solve(open("../data/day22.test")) == (
    6032,
    5031
  )
end

p(c) = @match c begin
          ' ' => -1
          '.' => 0
          '#' => 1
        end

re = r"(?<N>\d+)(?<D>\w)"

function load(file)
  lines = readlines(file)
  N = length(lines) - 2
  M = maximum(length.(lines[1:end-1]))
  grid = -ones(Int, N, M)
  for i in 1:N
    grid[i,1:length(lines[i])] = p.(collect(lines[i]))
  end
  insts = Vector{Tuple{Int, Char}}()
  for m in eachmatch(re, lines[end])
    D = collect(m[:D])[1]
    N = D == 'L' || D == 'R' ? m[:N] : m[:N] * m[:D]
    D = D == 'L' || D == 'R' ? D : '_'
    push!(insts, (parse(Int, N), D))
  end
  grid, insts
end

struct Position
  x::Int
  y::Int
  dir::Char
end

const dirs = ['>', 'v', '<', '^']

score(p::Position) = 1000 * (p.x) + 4 * (p.y) + findfirst(x->x==p.dir, dirs,)[1] - 1

wrap(i, N) = mod(i - 1, N) + 1

function turn(dir, rot)
  index = findfirst(x->x==dir, dirs)
  @match rot begin
    'R' => dirs[wrap(index + 1, 4)]
    'L' => dirs[wrap(index - 1, 4)]
  end
end  

function next(grid, state)
  N, M = size(grid)
  x, y = @match state.dir begin
    '>' => (state.x, wrap(state.y + 1, M))
    'v' => (wrap(state.x + 1, N), state.y)
    '<' => (state.x, wrap(state.y - 1, M))
    '^' => (wrap(state.x - 1, N), state.y)
  end
  Position(x, y, state.dir)
end

function walk(grid, state, inst)
  last = state
  for i in 1:inst[1] 
    current = next(grid, last)
    while grid[current.x, current.y] == -1
      current = next(grid, current)
    end
    if grid[current.x, current.y] == 1
      break
    end
    last = current
  end
  Position(last.x, last.y, inst[2] == '_' ? last.dir : turn(last.dir, inst[2]))
end

function walk_grid(grid, insts, first)
  state = first
  for inst in insts
    state = walk(grid, state, inst)
  end
  state
end

function problem1(data)
  grid, insts = data
  println(size(grid))
  start = findfirst(x->x==0,grid[1,:])[1]
  first = Position(1, start, '>')
  last = walk_grid(grid, insts, first)
  score(last)
end

function problem2(data)

end

function solve(io::IO)
  data = load(io)
  (
    problem1(deepcopy(data)),
    #problem2(deepcopy(data))
  )
end

end