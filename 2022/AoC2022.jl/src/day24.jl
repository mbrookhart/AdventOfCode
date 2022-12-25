module day24

using InlineTest
using Match
using DataStructures

@testset "day24" begin
  @test solve(open("../data/day24.test")) == (
    18,
    54
  )
end

struct Blizzard
  x::Int
  y::Int
  dir::Char
end

function load(file)
  grid = mapreduce(permutedims,vcat,collect.(readlines(file)))
  N, M = size(grid)
  blizzards = Vector{Blizzard}()
  for j in 2:M-1
    for i in 2:N-1
      @match grid[i,j] begin
        '.' => nothing
        _ => push!(blizzards, Blizzard(i, j, grid[i,j]))
      end
    end
  end
  new_grid = Matrix{Int}(undef, N, M)
  for j in 1:M
    for i in 1:N
      new_grid[i,j] = @match grid[i,j] begin
        '.' => 0
        '#' => -1
        _ => 1
      end
    end
  end
  new_grid, blizzards
end

wrap(i, N) = mod(i - 2, N - 2) + 2

function move_blizzards(grid, blizzards)
  N, M = size(grid)
  new_blizzards = Vector{Blizzard}()
  for b in blizzards
    push!(new_blizzards, @match b.dir begin
      '>' => Blizzard(b.x, wrap(b.y + 1, M), b.dir)  
      '<' => Blizzard(b.x, wrap(b.y - 1, M), b.dir) 
      '^' => Blizzard(wrap(b.x - 1, N), b.y, b.dir) 
      'v' => Blizzard(wrap(b.x + 1, N), b.y, b.dir) 
    end)
  end
  new_blizzards
end

function update_grid(grid, blizzards)
  N, M = size(grid)
  grid = deepcopy(grid)
  blizzards = move_blizzards(grid, blizzards)
  grid[2:N-1, 2:M-1] .= 0
  for b in blizzards
    grid[b.x, b.y] += 1
  end
  grid, blizzards
end

struct Position
  x::Int
  y::Int
  t::Int
end

mutable struct Pathfinder{K,T}
  map::K # Problem map to pass into generation logic
  queue::PriorityQueue{T} # queue for Astar
  cost::Dict{T, Int} # cost for Astar
  path::Dict{T, T} # path for Astar
  goal::T # goal for Astar
end

function Pathfinder(map, start::T, goal::T, initial_cost=0) where {T}
  cost = Dict{T, Int}()
  cost[start] = initial_cost
  queue = PriorityQueue{T, Int}()
  path = Dict{T, T}()
  enqueue!(queue, start, initial_cost)
  Pathfinder(map, queue, cost, path, goal)
end

function Astar(p::Pathfinder)
  while length(p.queue) > 0
    current = dequeue!(p.queue)
    if all((current.x, current.y) .== (p.goal.x, p.goal.y))
      return current
    end
    for next in generate_moves(p, current)
      new_cost = get_new_cost(p, current, next)
      if !(next in keys(p.cost)) || (new_cost < p.cost[next])
        p.cost[next] = new_cost
        priority = new_cost + heuristic(p, next)
        if haskey(p.queue, next)
          if p.queue[next] > priority
            p.queue[next] = priority
          end
        else 
          enqueue!(p.queue, next, priority)
        end
      end
    end
  end
end

get_new_cost(p, current, next) = p.cost[current] + 1

function generate_moves(p, current::T) where {T}
  if length(p.map) <= current.t + 1
    push!(p.map, update_grid(p.map[end]...))
  end
  moves = Vector{T}()
  grid, _ = p.map[current.t + 1]
  N, M = size(grid)
  inbounds(x,y) = (x >= 1) && (x <= N) && (y >= 1) && (y <= M)
  for loc in ((current.x, current.y),
              (current.x - 1, current.y),
              (current.x + 1, current.y),
              (current.x, current.y - 1),
              (current.x, current.y + 1))
    if inbounds(loc...) && grid[loc...] == 0
      push!(moves, Position(loc..., current.t + 1))
    end
  end
  moves
end

heuristic(p, next) = round(sum((p.goal.x - next.x, p.goal.y - next.y) .^ 2) .^ .5)

function problem1(data)
  grid, blizzards = data
  N, M = size(grid)
  states = [(grid, blizzards)]
  p = Pathfinder(states, Position(1, 2, 1), Position(N, M - 1, 1))
  Astar(p).t - 1 # Julia is 1 indexed
end

function problem2(data)
  grid, blizzards = data
  N, M = size(grid)
  states = [(grid, blizzards)]
  p = Pathfinder(states, Position(1, 2, 1), Position(N, M - 1, 1))
  next_start = Astar(p)
  p = Pathfinder(p.map, next_start, Position(1, 2, 1))
  back_to_entrance = Astar(p)
  p = Pathfinder(p.map, back_to_entrance, Position(N, M - 1, 1))
  Astar(p).t - 1
end

function solve(io::IO)
  data = load(io)
  (
    problem1(deepcopy(data)),
    problem2(deepcopy(data))
  )
end

end