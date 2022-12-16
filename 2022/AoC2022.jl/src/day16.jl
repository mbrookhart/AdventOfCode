module day16

using InlineTest
using DataStructures

@testset "day16" begin
  @test problem1(load(open("../data/day16.test"))) == 1651
  @test problem2(load(open("../data/day15.test")), 20) == 1707
end

re_valve = r"Valve (?<valve>\w+)"
re_rate = r"rate=(?<flow>\d+)"
function load(file)
  lines = readlines(file)
  rates = Dict{String, Int}()
  tunnels = Dict{String, Vector{String}}()
  for line in lines
    name = match(re_valve, line)[:valve]
    flow = parse(Int, match(re_rate, line)[:flow])
    ts = split(line, "valve")[2]
    if startswith(ts, "s")
      ts = ts[2:end]
    end
    t = strip.(String.(split(ts, ",")))
    rates[name] = flow
    tunnels[name] = t
  end
  rates, tunnels
end

struct Pathfinder{K,T}
  map::K # Problem map to pass into generation logic
  queue::PriorityQueue{T} # queue for Astar
  cost::Dict{T, Int} # cost for Astar
  goal::T # goal for Astar
end

function Pathfinder(map, start::T, goal::T, initial_cost=0) where {T}
  cost = Dict{T, Int}()
  cost[start] = initial_cost
  queue = PriorityQueue{T, Int}()
  enqueue!(queue, start, initial_cost)
  Pathfinder(map, queue, cost, goal)
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


get_new_cost(p, current, next) = p.cost[current] + 1

generate_moves(p, current) = p.map[2][current]

heuristic(p, next) = 0

key(start, stop) = start * "=>" * stop

function generate_distances(rates, tunnels)
  out = Dict{String, Int}()
  for start in keys(tunnels)
    for stop in keys(tunnels)
      p = Pathfinder((rates, tunnels), start, stop)
      Astar(p)
      out[key(start, stop)] = p.cost[stop]
    end
  end
  out
end


function traverse(rates, distances, room::String, valves, time=30)
  rate = 0
  if time > 0
    if room in valves
      pop!(valves, room)
      time = time - 1
      rate += time * rates[room]
    end
    rs = Vector{Int}()
    for valve in valves
      time_at_valve = time - distances[key(room, valve)]
      push!(rs, traverse(rates, distances, valve, copy(valves), time_at_valve))
    end
    rate += maximum(rs, init=0)
  end
  rate
end

function problem1(A)
  rates, tunnels = A
  distances = generate_distances(rates, tunnels)
  valves = Set(k for (k,v) in rates if v > 0)
  traverse(rates, distances, "AA", valves)
end

function problem2(A)
end

function solve(io::IO)
  A = load(io)
  (
    problem1(A),
    #problem2(A)
  )
end

end