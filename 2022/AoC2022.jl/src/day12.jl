module day12

using InlineTest
using DataStructures
using Profile
using BenchmarkTools

@testset "day12" begin
  @test solve(open("../data/day12.test")) == (
    31,
    29
  )
end

function load(file)
  mapreduce(permutedims,vcat,collect.(readlines(file)))
end

struct Pathfinder{K,T}
  map::K # Problem map to pass into generation logic
  queue::PriorityQueue{T} # queue for Astar
  cost::Dict{T, Int} # cost for Astar
  goal::T # goal for Astar
end

function Astar(p::Pathfinder)
  while length(p.queue) > 0
    current = dequeue!(p.queue)
    if current == p.goal
      break
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

Loc = Vector{Int}

heuristic(p, next) = 0

function generate_moves(p, current)
  N,M = size(p.map)
  inbounds(x) = (x[1] >= 1) & (x[1] <= N) & (x[2] >= 1) & (x[2] <= M)
  i,j = current
  moves = filter(inbounds, [[i, j - 1], [i, j + 1], [i - 1, j], [i + 1, j]])
  climbs(x) = Int(p.map[x...]) <= Int(p.map[current...]) + 1
  moves = filter(climbs, moves)
  moves
end

function get_new_cost(p, current, next)
  p.cost[current] + 1
end

function problem1(A) 
  A = deepcopy(A)
  queue = PriorityQueue{Loc, Int}()
  start = [Tuple(findfirst(x->x=='S', A))...]
  A[start...] = 'a'
  queue = PriorityQueue{Loc, Int}()
  enqueue!(queue, start, 0)
  cost = Dict{Loc, Int}() 
  cost[start] = 0
  goal = [Tuple(findfirst(x->x=='E', A))...]
  A[goal...] = 'z'
  p = Pathfinder(A, queue, cost, goal)
  Astar(p)
  p.cost[p.goal]
end

function problem2(A) 
  A = deepcopy(A)
  start = Tuple(findfirst(x->x=='S', A))
  A[start...] = 'a'
  As = Tuple.(findall(x->x=='a', A))
  queue = PriorityQueue{Loc, Int}()
  cost = Dict{Loc, Int}() 
  for start in As
    enqueue!(queue, [start...], 0)
    cost[[start...]] = 0
  end
  goal = [Tuple(findfirst(x->x=='E', A))...]
  A[goal...] = 'z'
  p = Pathfinder(A, queue, cost, goal)
  Astar(p)
  p.cost[p.goal]
end

function solve(io::IO)
  A = load(io)
  (
    problem1(A),
    problem2(A)
  )
end

end