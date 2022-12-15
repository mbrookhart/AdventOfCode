module day14

using InlineTest
using DataStructures
using SparseArrays

@testset "day14" begin
  @test solve(open("../data/day14.test")) == (
    24,
    93
  )
end

function get_segments(line)
  p(x) = parse.(Int64, split(x, ",")) .+ 1 # Julia is 1 indexed
  p.(split(line, "->"))
end

function load(file)
  lines = readlines(file)
  get_segments.(lines)
end

function create_grid(segments)
  N = 1001
  M = 1001
  grid = spzeros(N, M)
  # This is nested loop hell
  for segment in segments
    for i in 1:length(segment) -1
      start = segment[i]
      stop = segment[i+1]
      if start[1] == stop[1]
        f = min(start[2], stop[2])
        l = max(start[2], stop[2])
        grid[start[1], f:l] .= 1
      else
        f = min(start[1], stop[1])
        l = max(start[1], stop[1])
        grid[f:l, start[2]] .= 1
      end
    end
  end
  grid
end

function simulate!(grid, ymax)
  while true
    x = 501
    y = 1
    while true
      # If we're past the end of the rocks and falling forever, exit
      if y >= ymax
        return
      # fall down
      elseif grid[x, y + 1] == 0
        y += 1
        continue
      # fall down+left
      elseif grid[x - 1, y + 1] == 0
        x -= 1
        y += 1
        continue
      # fall down+righ
      elseif grid[x + 1, y + 1] == 0
        x += 1
        y += 1
        continue
      end
      break
    end
    # place sand where it stopped
    grid[x, y] = 2
    # if we've clogged the spout, exit
    if x == 501 && y == 1
      return
    end
  end
end

function problem1(pairs)
  grid = create_grid(pairs)
  columns = sum(grid, dims=1)
  ymax = findlast(x->x>0, columns)[2]
  simulate!(grid, ymax)
  sum(grid .== 2)
end

function problem2(pairs)
  grid = create_grid(pairs)
  columns = sum(grid, dims=1)
  ymax = findlast(x->x>0, columns)[2] + 2
  grid[:, ymax] .= 1
  simulate!(grid, ymax)
  sum(grid .== 2)
end

function solve(io::IO)
  A = load(io)
  (
    problem1(A),
    problem2(A)
  )
end

end