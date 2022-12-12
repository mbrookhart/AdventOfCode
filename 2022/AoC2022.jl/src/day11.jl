module day11

using InlineTest
using Match
using Profile
using BenchmarkTools

T = Int64

mutable struct Monkey
  id::T
  items::Array{T}
  operation
  test_div::T
  t_throw::T
  f_throw::T
  n_inspections::T
end

Base.isless(a::Monkey, b::Monkey) = a.n_inspections < b.n_inspections

struct Monkeys
  monkeys::Vector{Monkey}
  lcd::T
end

Monkeys(monkeys::Vector{Monkey}) = Monkeys(monkeys, lcm([m.test_div for m in monkeys]))
Base.size(s::Monkeys) = size(s.monkeys)
Base.length(s::Monkeys) = length(s.monkeys)
Base.getindex(s::Monkeys, i::Int) = s.monkeys[i]
Base.isless(a::Monkeys, b::Monkeys) = a[1]<b[1] 
Base.sort!(a::Monkeys; rev=true) = sort!(a.monkeys, rev=true)

@testset "day11" begin
  @test solve(open("../data/day11.test")) == (
    10605,
    2713310158
  )
end

function load(file)
  monkeys = Vector{Monkey}()
  lines = readlines(file)
  for i in 1:length(lines)
    if startswith(lines[i], "Monkey")
      id = parse.(T, split(split(lines[i], " ")[2], ":")[1])
      items = parse.(T, split(split(lines[i+1], ":")[2],","))
      op_desc = split(strip(split(lines[i+2], "=")[2]), " ")
      if op_desc[2] == "*"
        operation = x -> x * (op_desc[3] == "old" ? x : parse(T, op_desc[3]))
      elseif  op_desc[2] == "+"
        operation = x -> x + parse(T, op_desc[3])
      end
      test_div = parse(T, split(lines[i+3], " ")[end])
      t_throw = parse(T, split(lines[i+4], " ")[end]) + 1 #Julia is 1 indexed
      f_throw = parse(T, split(lines[i+5], " ")[end]) + 1 #Julia is 1 indexed
      push!(monkeys, Monkey(id, items, operation, test_div, t_throw, f_throw, T(0)))
    end
  end
  Monkeys(monkeys)
end

function turn!(monkeys::Monkeys, pos, divisor)
  monkey = monkeys[pos]
  for item in monkey.items
    worry = monkey.operation(item) ÷ divisor
    worry = mod(worry, monkeys.lcd)
    if mod(worry, monkey.test_div) == T(0)
      push!(monkeys[monkey.t_throw].items, worry)
    else
      push!(monkeys[monkey.f_throw].items, worry)
    end
    monkey.n_inspections += T(1)
  end
  empty!(monkey.items)
end

function round!(monkeys::Monkeys, divisor::T)
  for i = 1:length(monkeys)
    turn!(monkeys, i, divisor)
  end
end

function toss(monkeys, N, divisor)
  monkeys = deepcopy(monkeys)
  for i in 1:N
    round!(monkeys, divisor)
  end
  sort!(monkeys, rev=true)
  monkeys[1].n_inspections * monkeys[2].n_inspections
end

problem1(monkeys) = toss(monkeys, 20, 3)
problem2(monkeys) = toss(monkeys, 10000, 1)

function solve(io::IO)
  monkeys = load(io)
  (
    problem1(monkeys),
    problem2(monkeys)
  )
end

end