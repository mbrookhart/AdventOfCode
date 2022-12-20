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

struct Blueprint
  id::Int
  robot_costs::NTuple{4, NTuple{4, Int}}
  max_spend::Tuple{Int,Int,Int,Int}
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

const bot_production = ((1,0,0,0),(0,1,0,0),(0,0,1,0),(0,0,0,1))

function parse_blueprint(line)
  id       = parse(Int, match(r_id, line)[:id])
  ore      = (parse(Int, match(r_ore, line)[:ore]), 0, 0, 0)
  clay     = (parse(Int, match(r_clay, line)[:ore]), 0, 0, 0)
  o_cost   = match(r_obsidian, line)
  obsidian = (parse(Int, o_cost[:ore]), parse(Int, o_cost[:clay]), 0, 0)
  g_cost   = match(r_geode, line)
  geode    = (parse(Int, g_cost[:ore]), 0, parse(Int, g_cost[:obsidian]), 0)
  
  robots = (ore, clay, obsidian, geode)
  Blueprint(id, robots, reduce((a, b) -> max.(a, b), robots))
end

load(file) = parse_blueprint.(readlines(file))

produce_resources(s::State) = s.resources .+ s.rpt

step_time(s::State) = State(produce_resources(s), s.rpt, s.time - 1)

function buy(s::State, b::Blueprint, bot, memo)
  max_spend = b.max_spend
  if bot == 4 || s.rpt[bot] < max_spend[bot]
    costs = b.robot_costs[bot]
    resources = s.resources
    if all(s.rpt[i] > 0 || costs[i] == 0 for i in 1:3)
      f((a,b)) = b > 0 ? cld(a, b) : 0
      wait = mapreduce(f, max, zip(costs .- resources, s.rpt))
      if s.time - wait - 1 > 0
        for i in 1:wait
          s = step_time(s)
        end
        s = State(s.resources .- costs, s.rpt, s.time)
        resources = produce_resources(s)
        new_rpt = s.rpt .+ bot_production[bot]
        resources = (min(resources[1], max_spend[1] * s.time),
                     min(resources[2], max_spend[2] * s.time),
                     min(resources[3], max_spend[3] * s.time),
                     resources[4])
        s = State(resources,
                  new_rpt,
                  s.time - 1)
        return search(s, b, memo)
      end
    end
  end
  0
end

function search(s::State, b::Blueprint, memo)
  if s in keys(memo)
    return memo[s]
  end
  if s.time == 0
    return s.resources[4]
  end
  # produce at current level for the rest of time
  geodes = s.resources[4] + s.rpt[4] * s.time
  # or wait until we can buy soemthing else
  for bot in 1:4
    geodes = max(geodes, buy(s, b, bot, memo))
  end
  memo[s] = geodes
  geodes
end

function find_max_geodes(blueprint, N=24)
  println(blueprint)
  memo = Dict{State, Int}()
  s = State((0,0,0,0), (1, 0, 0, 0), N)
  search(s, blueprint, memo)
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