module day15

using InlineTest


@testset "day15" begin
  @test problem1(load(open("../data/day15.test")), 10) == 26
  @test tuning_frequency(Beacon(14, 11)) == 56000011
  @test problem2(load(open("../data/day15.test")), 20) == 56000011
end

struct Beacon
  x::Int
  y::Int
end

struct Sensor
  x::Int
  y::Int
  d::Int #distance to closest beacon
end

manhattan_distance(a, b) = abs(a.x - b.x) + abs(a.y - b.y)

i(x) = parse(Int, x)

re = r"x=(?<x>[-+]?\d+), y=(?<y>[-+]?\d+)"

function Beacon(s) 
  m = match(re, s)
  Beacon(i(m[:x]), i(m[:y]))
end

function Sensor(s, b::Beacon) 
  m = match(re, s)
  Sensor(i(m[:x]), i(m[:y]), manhattan_distance(Beacon(i(m[:x]), i(m[:y])), b))
end

function load(file)
  lines = readlines(file)
  get_beacons(line) = Beacon(split(line,":")[2])
  get_sensors((line, beacon)) = Sensor(split(line,":")[1], beacon)
  beacons = get_beacons.(lines)
  sensors = get_sensors.(zip(lines, beacons))
  sensors, beacons
end

@inbounds function merge_range(a, b)
  s,l = a[1] < b[1] ? (a, b) : (b, a)
  s[2] >= l[1] ? (s[1], max(l[2], s[2])) : nothing
end

function overlap_lines(lines)
  out = Vector{Tuple{Int64, Int64}}()
  lines = sort(lines)
  push!(out, lines[1])
  for i = 2:length(lines)
    m = merge_range(out[end], lines[i])
    if m == nothing
      push!(out, lines[i])
    else
      out[end] = m
    end
  end
  out
end

function sum_overlap(lines)
  s = 0
  for l in lines
    s += l[2] - l[1]
  end
  s
end

function get_sensor_regions(sensors, y)
  out = Vector{Tuple{Int, Int}}()
  for sensor in sensors
    d = sensor.d - abs(sensor.y - y)
    if d >= 0 
      push!(out, (sensor.x - d, sensor.x + d))
    end
  end
  out
end

function problem1(A, line=2000000)
  sensors, beacons = A
  lines = get_sensor_regions(sensors, line)
  lines = overlap_lines(lines)
  sum_overlap(lines)
end

function intersect_lines(lines, limit)
  out = Vector{Tuple{Int64, Int64}}()
  for line in lines
    l,r = line
    l = l < limit[1] ? limit[1] : l
    r = r > limit[2] ? limit[2] : r
    push!(out, (l,r))
  end
  out
end

tuning_frequency(b) = b.x * 4000000 + b.y

function problem2(A, lim=4000000)
  sensors, beacons = A
  for i in 1:lim
    lines = get_sensor_regions(sensors, i)
    lines =  overlap_lines(lines)
    lines = intersect_lines(lines, (0, lim))
    s = sum_overlap(lines)
    if s != lim
      y = i
      x = (lines[1][2] + lines[2][1]) ÷ 2
      return tuning_frequency(Beacon(x, y))
    end
  end
end

function solve(io::IO)
  A = load(io)
  (
    problem1(A),
    problem2(A)
  )
end

end