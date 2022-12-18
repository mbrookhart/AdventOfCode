module day18

using InlineTest
using Match
using DataStructures

@testset "day18" begin
  @test solve(open("../data/day18.test")) == (
    64,
    58
  )
end

Cube{T} = Tuple{T, T, T}

p(x) = Cube((parse.(Int, split(x, ",")) .+ 2))

function load(file)
  p.(readlines(file))
end

function erase_surface!(surfaces, cubes, i, j, n, m)
 surfaces[cubes[i]][n] = 0
 surfaces[cubes[j]][m] = 0
end

function get_surface_area(cubes)
  surfaces = Dict{Cube, Vector{Int}}(c=>ones(Int, 6) for c in cubes)
  for i in 1:length(cubes)
    for j in i+1:length(cubes)
      @match cubes[i] .- cubes[j] begin
        ( 1,  0,  0) => erase_surface!(surfaces, cubes, i, j, 1, 4)
        (-1,  0,  0) => erase_surface!(surfaces, cubes, i, j, 4, 1)
        ( 0,  1,  0) => erase_surface!(surfaces, cubes, i, j, 2, 5)
        ( 0, -1,  0) => erase_surface!(surfaces, cubes, i, j, 5, 2)
        ( 0,  0,  1) => erase_surface!(surfaces, cubes, i, j, 3, 6)
        ( 0,  0, -1) => erase_surface!(surfaces, cubes, i, j, 6, 3)
      end
    end
  end
  surfaces
end

function problem1(A)
  surfaces = get_surface_area(A)
  sum(sum.(values(surfaces)))
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
    if current == p.goal
      return false
    end
    for next in generate_moves(p, current)
      if next in keys(p.map[2]) && !p.map[2][next]
        return false
      end
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
  return true
end

get_new_cost(p, current, next) = p.cost[current] + 1

function generate_moves(p, current) 
  N, M, O = size(p.map[1])
  inbounds(i, j, k) = i > 0 && i <= N && j > 0 && j <= M && k > 0 && k <= O
  i,j,k = current
  out = Vector{Cube{Int}}()
  for c in [(i-1, j, k),(i, j-1, k),
            (i, j, k-1),(i+1, j, k),
            (i, j+1, k),(i, j, k+1)]
    if inbounds(c...) && p.map[1][c...] == 0
      push!(out, c)
    end
  end
  out
end

heuristic(p, next) = round(sum((p.goal .- next) .^ 2) .^ .5)

function clear!(q::PriorityQueue) 
  while length(q) > 0
    dequeue!(q)
  end
end

function is_void(grid, memo, i, j, k)
  p = Pathfinder((grid, memo), (i,j,k), (1,1,1))
  b = Astar(p)
  memo[(i,j,k)] = b
  b
end

function problem2(A)
  N = maximum(maximum.(A)) + 1
  grid = zeros(Int, N, N, N)
  for c in A
    grid[c...] = 1
  end
  memo = Dict{Cube, Bool}()
  ec = Vector{Cube}()
  for k in 1:N
    for j in 1:N
      for i in 1:N
        if grid[i, j, k] == 0 && is_void(grid, memo, i, j, k)
          push!(ec, (i, j, k))
        end
      end
    end
  end
  for c in ec
    push!(A, c)
  end
  surfaces = get_surface_area(A)
  for c in ec
    pop!(surfaces, c)
  end
  sum(sum.(values(surfaces)))
end

function solve(io::IO)
  A = load(io)
  (
    problem1(deepcopy(A)),
    problem2(deepcopy(A))
  )
end

end