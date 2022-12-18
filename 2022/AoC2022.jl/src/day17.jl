module day17

using InlineTest
using SparseArrays
using Match

@testset "day17" begin
  @test solve(open("../data/day17.test")) == (
    3068, 
    #1707
    )
end

mutable struct Gusts
  gusts::Vector{Char}
  index::Int
end

Gusts(gusts) = Gusts(gusts, 0)

Base.size(s::Gusts) = size(s.gusts)
Base.length(s::Gusts) = length(s.gusts)

function get(s::Gusts) 
  s.index += 1
  if s.index > length(s)
    s.index = 1
  end
  s.gusts[s.index]
end

T = Bool

function gen_rocks()
  rocks = Vector{SparseMatrixCSC{T, Int}}()
  # minus
  tmp = spzeros(T, 1, 4)
  tmp[1, :] .= 1
  push!(rocks, tmp)
  # plus
  tmp = spzeros(T, 3, 3)
  tmp[3, 2] = 1
  tmp[2, 1:3] .= 1
  tmp[1, 2] = 1
  push!(rocks, tmp)
  # angle
  tmp = spzeros(T, 3, 3)
  tmp[1, 1:3] .= 1
  tmp[1:3, 3] .= 1
  push!(rocks, tmp)
  # l
  tmp = spzeros(T, 4, 1)
  tmp[:, 1] .= 1
  push!(rocks, tmp)
  # square
  tmp = spzeros(T, 2, 2)
  tmp[:,:] .= 1
  push!(rocks, tmp)
  rocks
end

top_of_grid(grid) = findfirst(x->x==0,sum(grid, dims=2))[1] - 1

function rock_hit(grid, rock, x, y)
  h, w = size(rock)
  x == 0 || sum(grid[x:x+h-1, y:y+w-1] .& rock) != 0
end

function drop_rock!(grid, rock, gusts)
  h, w = size(rock)
  x, y = top_of_grid(grid) + 4, 3
  while !rock_hit(grid, rock, x, y)
    ### Push the rock
    g = get(gusts)
    new_y = @match g begin
      '>' => y + w - 1 < 7 ? y + 1 : y
      '<' => y > 1 ? y - 1 : y
    end
    ### If we hit something in the gust, revert
    y = rock_hit(grid, rock, x, new_y) ? y : new_y
    ### Drop the rock
    x = x - 1
  end
  ## Mark the rock's final landing place, adding 1 to x to revert the last drop
  grid[x+1:x+h, y:y+w-1] .|= rock
end

function drop_rocks!(grid, rocks, gusts)
  for i in 0:2021
    drop_rock!(grid, rocks[mod(i, 5) + 1], gusts)
  end
end

function problem1(gusts)
  rocks = gen_rocks()
  grid = spzeros(T, 10000, 7)
  drop_rocks!(grid, rocks, gusts)
  top_of_grid(grid)
end

function problem2(A)
end

function load(file)
  Gusts(collect(readlines(file)[1]))
end

function solve(io::IO)
  A = load(io)
  (
    problem1(A),
    #problem2(A)
  )
end

end