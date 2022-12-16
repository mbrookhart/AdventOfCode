module day16

using InlineTest
using DataStructures
using BenchmarkTools
using Profile

@testset "day16" begin
  @test solve(open("../data/day16.test")) == (1651, 1707)
end

re_valve = r"Valve (?<valve>\w+)"
re_rate = r"rate=(?<flow>\d+)"
function load(file)
  lines = readlines(file)
  codes = Dict{String, Int}()
  rates = Dict{String, Int}()
  tunnels = Dict{String, Vector{String}}()
  for (i,line) in enumerate(lines)
    name = match(re_valve, line)[:valve]
    codes[name] = i
    flow = parse(Int, match(re_rate, line)[:flow])
    ts = split(line, "valve")[2]
    if startswith(ts, "s")
      ts = ts[2:end]
    end
    t = strip.(String.(split(ts, ",")))
    rates[name] = flow
    tunnels[name] = t
  end
  codes, Dict(codes[k]=>v for (k,v) in rates), Dict(codes[k]=>[codes[i] for i in v] for (k,v) in tunnels)
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

key(start, stop) = (start, stop)
key(room, time, valves) = (room, time, valves)

function generate_distances(rates::Dict{T, Int}, tunnels::Dict{T, Vector{T}}) where {T}
  out = Dict{Tuple{T, T}, Int}()
  for start in keys(tunnels)
    for stop in keys(tunnels)
      p = Pathfinder((rates, tunnels), start, stop)
      Astar(p)
      out[key(start, stop)] = p.cost[stop]
    end
  end
  out
end

function traverse(rates, distances, memo, room::T, valves, time=30) where {T}
  key1 = key(room, time, valves)
  val = get(memo, key1, nothing)
  if val != nothing 
    return val
  end
  rs = Vector{Int}()
  for valve in valves
    # Move to new room based on pre-calcualted distance
    time_at_valve = time - distances[key(room, valve)]
    if time_at_valve > 0
      new_valves = [v for v in valves if v != valve]
      valve_pressure = (time_at_valve - 1) * rates[valve]
      push!(rs, valve_pressure + traverse(rates, distances, memo, valve, new_valves, time_at_valve - 1))
    end
  end
  rate = maximum(rs, init=0)
  memo[key1] = rate
  rate
end

function traverse(rates, distances, memo, rooms::Tuple{T, T}, valves, times=(26, 26)) where {T}
  key1 = key(rooms, times, valves)
  key2 = key(reverse(rooms), reverse(times), valves)
  val = get(memo, key1, nothing)
  if val != nothing 
    return val
  end
  val = get(memo, key2, nothing)
  if val != nothing
    return val
  end
  i = argmax(times)
  j = i == 1 ? 2 : 1
  time = times[i]
  room = rooms[i]
  rs = Vector{Int}()
  for valve in valves
    time_at_valve = time - distances[key(room, valve)]
    if time_at_valve > 0
      # open_valve when we arrive at the next location
      new_valves = [v for v in valves if v != valve]
      valve_pressure = (time_at_valve - 1) * rates[valve]
      # Continue traversing from that state
      push!(rs, valve_pressure + traverse(rates, distances, memo, (valve, rooms[j]), new_valves, (time_at_valve - 1, times[j])))
    end
  end
  rate = maximum(rs, init=0)
  memo[key1] = rate
  memo[key2] = rate
  rate
end

function problem1(A)
  codes, rates, tunnels = A
  distances = generate_distances(rates, tunnels)
  valves = [k for (k,v) in rates if v > 0]
  memo = Dict{Tuple{Int, Int, Vector{Int}}, Int}()
  traverse(rates, distances, memo, codes["AA"], valves)
end

function problem2(A)
  codes, rates, tunnels = A
  distances = generate_distances(rates, tunnels)
  valves = [k for (k,v) in rates if v > 0]
  memo = Dict{Tuple{Tuple{Int, Int}, Tuple{Int, Int}, Vector{Int}}, Int}()
  traverse(rates, distances, memo, (codes["AA"], codes["AA"]), valves)
end

function solve(io::IO)
  A = load(io)
  (
    problem1(A),
    problem2(A)
  )
end

end