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

function gen_rocks()
  rocks = Vector{Array{Int, 2}}()
  # minus
  tmp = zeros(Int, 1, 4)
  tmp[1, :] .= 1
  push!(rocks, tmp)
  # plus
  tmp = zeros(Int, 3, 3)
  tmp[3, 2] = 1
  tmp[2, 1:3] .= 1
  tmp[1, 2] = 1
  push!(rocks, tmp)
  # angle
  tmp = zeros(Int, 3, 3)
  tmp[1, 1:3] .= 1
  tmp[1:3, 3] .= 1
  push!(rocks, tmp)
  # l
  tmp = zeros(Int, 4, 1)
  tmp[:, 1] .= 1
  push!(rocks, tmp)
  # square
  tmp = zeros(Int, 2, 2)
  tmp[:,:] .= 1
  push!(rocks, tmp)
  rocks
end

top_of_grid(grid) = findfirst(x->x==0,sum(grid, dims=2))[1] - 1

function drop_rock!(grid, rock, gusts)
  h, w = size(rock)
  x, y = top_of_grid(grid) + 4, 3
  while true
    ### Push the rock
    g = get(gusts)
    new_y = @match g begin
      '>' => y + w - 1 < 7 ? y + 1 : y
      '<' => y > 1 ? y - 1 : y
    end
    ### Check if we hit a fallen rock, if so, negate push
    if sum(grid[x:x+h-1, new_y:new_y+w-1] .& rock) != 0
      new_y = y
    end
    y = new_y
    ### Fall the rock
    new_x = x - 1
    ### Check if we landed
    if new_x == 0 || sum(grid[new_x:new_x+h-1, y:y+w-1] .& rock) != 0
      break
    end
    x = new_x
  end
  ## Mark the rock's final landing place
  grid[x:x+h-1, y:y+w-1] = rock
end

function drop_rocks!(grid, rocks, gusts)
  for i in 0:2021
    drop_rock!(grid, rocks[mod(i, 5) + 1], gusts)
  end
end

function problem1(gusts)
  rocks = gen_rocks()
  grid = spzeros(Int, 10000, 7)
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