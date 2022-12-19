module day19

using InlineTest
using Match
using DataStructures

@testset "day19" begin
  @test solve(open("../data/day19.test")) == (
    33,
    56*62
  )
end


@enum Resource Ore=1 Clay=2 Obsidian=3 Geode=4

struct Robot
  # produces ore, clay, obsidian, or geodes
  produces::Tuple{Int, Int, Int, Int}
  # costs ore, clay, or obsidian
  costs::Tuple{Int, Int, Int, Int}
end

struct Blueprint
  id::Int
  ore::Robot
  clay::Robot
  obsidian::Robot
  geode::Robot
end

struct State
  resources::Tuple{Int, Int, Int, Int}
  rpt::Tuple{Int, Int, Int, Int}
  time::Int
end

const K = 0x517cc1b727220a95;

function fxhash(a, h::UInt)
  xor(bitrotate(h, -5), a) * K
end

# Faster hashing
function Base.hash(a::State, h::UInt)
  h = foldr(fxhash, a.resources, init = h)
  h = foldr(fxhash, a.rpt, init = h)
  fxhash(a.time, h)
end

const r_id = r"Blueprint (?<id>\d+)"
const r_ore = r"ore robot costs (?<ore>\d+)"
const r_clay = r"clay robot costs (?<ore>\d+)"
const r_obsidian = r"obsidian robot costs (?<ore>\d+) ore and (?<clay>\d+)"
const r_geode = r"geode robot costs (?<ore>\d+) ore and (?<obsidian>\d+)"

function parse_blueprint(line)
  id       = parse(Int, match(r_id, line)[:id])
  ore      = Robot((1,0,0,0), (parse(Int, match(r_ore, line)[:ore]), 0, 0, 0))
  clay     = Robot((0,1,0,0), (parse(Int, match(r_clay, line)[:ore]), 0, 0, 0))
  o_cost   = match(r_obsidian, line)
  obsidian = Robot((0,0,1,0), (parse(Int, o_cost[:ore]), parse(Int, o_cost[:clay]), 0, 0))
  g_cost   = match(r_geode, line)
  geode    = Robot((0,0,0,1), (parse(Int, g_cost[:ore]), 0, parse(Int, g_cost[:obsidian]), 0))
  Blueprint(id, ore, clay, obsidian, geode)
end

load(file) = parse_blueprint.(readlines(file))

can_buy(s::State, r::Robot) = all(s.resources .>= r.costs)
buy(s::State, r::Robot) = State(s.resources .- r.costs, s.rpt, s.time)

produce_resources(s::State) = s.resources .+ s.rpt

step_time(s::State) = State(produce_resources(s), s.rpt, s.time + 1)

function step_time(s::State, r::Robot)
  s = buy(s, r)
  State(produce_resources(s), s.rpt .+ r.produces, s.time + 1)
end

function search(s::State, b::Blueprint, memo, N)
  if s in keys(memo)
    return memo[s]
  end
  out = 0
  if s.time < N
    os = Vector{Int}()
    if can_buy(s, b.geode)
      push!(os, search(step_time(s, b.geode   ), b, memo, N))
    else
      push!(os, search(step_time(s), b, memo, N))
      if can_buy(s, b.ore)
        push!(os, search(step_time(s, b.ore     ), b, memo, N))
      end
      if can_buy(s, b.clay)
        push!(os, search(step_time(s, b.clay    ), b, memo, N))
      end
      if can_buy(s, b.obsidian)
        push!(os, search(step_time(s, b.obsidian), b, memo, N))
      end
    end
    out = maximum(os)
  else
    out = s.resources[end]
  end
  memo[s] = out
  out
end

function find_max_geodes(blueprint, N=24)
  println(blueprint)
  memo = Dict{State, Int}()
  s = State((0,0,0,0), blueprint.ore.produces, 0)
  search(s, blueprint, memo, N)
end

quality(blueprint) = blueprint.id * find_max_geodes(blueprint)

problem1(A) = sum(quality.(A))

problem2(A) = prod(find_max_geodes.(A[1:min(end, 3)], 32))

function solve(io::IO)
  A = load(io)
  (
    problem1(deepcopy(A)),
    problem2(deepcopy(A))
  )
end

end