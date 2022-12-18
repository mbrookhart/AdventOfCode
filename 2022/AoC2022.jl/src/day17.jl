module day17

using InlineTest
using SparseArrays
using Match

@testset "day17" begin
  @test solve(open("../data/day17.test")) == (
    3068, 
    1514285714288
    )
end

# explicitly mark out the rocks we want to drop
function gen_rocks()
  rocks = Vector{Matrix{T}}()
  # minus
  tmp = zeros(T, 1, 4)
  tmp[1, :] .= 1
  push!(rocks, tmp)
  # plus
  tmp = zeros(T, 3, 3)
  tmp[3, 2] = 1
  tmp[2, 1:3] .= 1
  tmp[1, 2] = 1
  push!(rocks, tmp)
  # angle
  tmp = zeros(T, 3, 3)
  tmp[1, 1:3] .= 1
  tmp[1:3, 3] .= 1
  push!(rocks, tmp)
  # l
  tmp = zeros(T, 4, 1)
  tmp[:, 1] .= 1
  push!(rocks, tmp)
  # square
  tmp = zeros(T, 2, 2)
  tmp[:,:] .= 1
  push!(rocks, tmp)
  rocks
end

# Gusts provides stateful access to the current location in the gusts
mutable struct Gusts
  gusts::Vector{Char}
  index::Int
end

Gusts(gusts) = Gusts(gusts, 0)

Base.length(s::Gusts) = length(s.gusts)

function get(s::Gusts) 
  s.index += 1
  if s.index > length(s)
    s.index = 1
  end
  s.gusts[s.index]
end

# The grid is meant to explicity store the top of the rock pile
# while representing the full height through an integer
mutable struct Grid{T}
  grid::Matrix{T}
  height::Int
end

T = Bool

top_of_grid(grid) = findfirst(x->x==0,sum(grid, dims=2))[1] - 1
top_of_grid(grid::Grid) = top_of_grid(grid.grid) + grid.height

function Base.getindex(grid::Grid, inds...)
  grid.grid[inds[1] .- grid.height, inds[2]]
end

function trim!(grid::Grid)
  L = Int(0.7 * size(grid.grid)[1])
  N = top_of_grid(grid.grid)
  if N > L
    grid.grid[1:L, :] = grid.grid[N-L+1:N,:]
    grid.grid[L+1:end, :] .= 0
    grid.height += N - L
  end
end

function rock_hit(grid, rock, x, y)
  h, w = size(rock)
  x == 0 || sum(grid[x:x+h-1, y:y+w-1] .& rock) != 0
end

function drop_rock!(grid, rock, gusts, memo)
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
  grid.grid[x+1 - grid.height:x+h - grid.height, y:y+w-1] .|= rock
  trim!(grid)
end

function drop_rocks!(grid, rocks, gusts, N)
  Key = Tuple{Matrix{T}, Int}
  memo = Dict{Key, Tuple{Matrix{T}, Int, Int, Int}}()
  memo_chain = Vector{Key}()
  i = 0
  while i < N - 1
    memoized = false
    gust_index = gusts.index
    key = deepcopy((grid.grid, gust_index))
    if key in keys(memo) && i < N - memo[key][4]
      ## update the grid with the memoized value
      g, hd, gi, num = memo[key]
      grid.grid = deepcopy(g)
      grid.height += hd
      gusts.index = gi
      i += num
      # when we have memoized multiple values back to back,
      # replace the memoized values with the extendend value
      # of the memoized chain
      for k in memo_chain
        new_num = memo[k][4] + num
        if new_num < N ÷ 10
          memo[k] = (g, memo[k][2] + hd, gi, memo[k][4] + num)
        end
      end
      # push the current memoized value onto the chain
      push!(memo_chain, key)
      continue
    else
      # run 5 rocks through the simulation
      old_height = top_of_grid(grid)
      lim = min(5, N - i)
      for j in 1:lim
        drop_rock!(grid, rocks[j], gusts, memo)
      end
      # Add the updated grid to the memo, reset the chain 
      memo_chain = Vector{Key}()
      memo[key] = (deepcopy(grid.grid), 
                   top_of_grid(grid) - old_height, 
                   gusts.index, lim)
      push!(memo_chain, key)
      i += lim
    end
  end
end


function simulate(gusts, N)
  rocks = gen_rocks()
  grid = Grid(zeros(T, 100, 7), 0)
  drop_rocks!(grid, rocks, gusts, N)
  top_of_grid(grid)
end

function problem1(gusts)
  simulate(gusts, 2022)
end

function problem2(gusts)
  simulate(gusts, 1000000000000)
end

function load(file)
  Gusts(collect(readlines(file)[1]))
end

function solve(io::IO)
  A = load(io)
  (
    problem1(deepcopy(A)),
    problem2(deepcopy(A))
  )
end

end