module day10

using InlineTest
using Match


@testset "day10" begin
  @test solve(open("../data/day10.test")) == (
    13140,
    """##..##..##..##..##..##..##..##..##..##..
###...###...###...###...###...###...###.
####....####....####....####....####....
#####.....#####.....#####.....#####.....
######......######......######......####
#######.......#######.......#######....."""
  )
end


function load(file)
  split.(readlines(file))
end

function execute_inst(inst, val="0")
  @match inst begin
    "noop" => (1, 0)
    "addx" => (2, parse(Int, val))
  end
end

function execute_program(insts, f)
  X = 1
  cycle = 1
  for inst in insts
    nc, update = execute_inst(inst...)
    for i in 1:nc
      f(cycle, X)
      cycle += 1
    end
    X += update
  end
end

function problem1(insts)
  sum = 0
  function sig_strength(cycle, X)
    if cycle in [20, 60, 100, 140, 180, 220]
      sum += cycle * X
    end
  end
  execute_program(insts, sig_strength)
  sum
end


function problem2(insts)
  CRT = Matrix{Char}(undef, (6, 40))
  CRT .= '.'
  function CRT_update(cycle, X)
    x, y = (cycle - 1) ÷ 40, mod(cycle - 1, 40)
    if abs(y - X) < 2
      CRT[x+1, y + 1] = '#'
    end
  end
  execute_program(insts, CRT_update)
  s=""
  for i in 1:6
    s = s * join(CRT[i,:]) * "\n"
  end
  println(s)
  chop(s)
end

function solve(io::IO)
  A = load(io)
  (
    problem1(A), 
    problem2(A)
  )
end

end