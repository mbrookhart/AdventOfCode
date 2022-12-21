module day21

using InlineTest
using Match

@testset "day21" begin
  @test solve(open("../data/day21.test")) == (
    152,
    301
  )
end

struct Monkey
  name::String
  op::String
  val::Int
  inputs::Vector{String}
end

function parse_monkey(line)
  name, operation = strip.(split(line, ":"))
  for c in ["+", "-", "*", "/"]
    if occursin(c, operation)
      return Monkey(String(name), c, -1, String.(split(operation, " "*c*" ")))
    end
  end
  val = parse(Int, operation)
  Monkey(String(name), "val", val, [])
end

function load(file)
  Dict(m.name=>m for m in parse_monkey.(readlines(file)))
end

function compute(monkeys, name)
  monkey = monkeys[name]
  @match monkeys[name].op begin
    "val" => monkey.val
    "+" => compute(monkeys, monkey.inputs[1]) + compute(monkeys, monkey.inputs[2])
    "-" => compute(monkeys, monkey.inputs[1]) - compute(monkeys, monkey.inputs[2])
    "*" => compute(monkeys, monkey.inputs[1]) * compute(monkeys, monkey.inputs[2])
    "/" => compute(monkeys, monkey.inputs[1]) / compute(monkeys, monkey.inputs[2])
  end
end

function problem1(data)
  Int(compute(data, "root"))
end

function problem2(data)
  root = data["root"]
  human = data["humn"]
  # make the root monkey do - so I can turn this into a root finding problem
  data["root"] = Monkey(root.name, "-", root.val, root.inputs)
  i = human.val
  fx = compute(data, "root")
  ## Use Newton's method to find the zero
  while fx != 0
    delta = Int(round(-.01*i))
    delta = delta == 0 ? -1 : delta
    # estimate the first derivtive as df/dx = (f(x + h) - f(x)) / h
    data["humn"] = Monkey(human.name, human.op, i + delta, human.inputs)
    df_dx = (compute(data, "root") - fx)/delta
    # doing the Newton's method update
    i = Int(round(i - fx / df_dx))
    data["humn"] = Monkey(human.name, human.op, i, human.inputs)
    fx = compute(data, "root")
  end
  return i
end

function solve(io::IO)
  A = load(io)
  (
    problem1(deepcopy(A)),
    problem2(deepcopy(A))
  )
end

end