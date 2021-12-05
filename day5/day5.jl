function load(file)
  lines = readlines(file)
  segments = Array{Int64, 2}(undef, length(lines), 4)
  for i in 1:length(lines)
    vals = split(lines[i], ",")
    mid_vals = split(vals[2], " -> ")
    segments[i,:] = [parse(Int64, vals[1]), 
                     parse(Int64, mid_vals[1]),
                     parse(Int64, mid_vals[2]),
                     parse(Int64, vals[3])]
  end
  # add one to the segments because Julia is 1 based
  segments .+= 1
  segments
end

function create_grid(segments)
  maxes = maximum(segments, dims=1)
  xmax = maximum([maxes[1], maxes[3]])
  ymax = maximum([maxes[2], maxes[4]])
  zeros((xmax, ymax))
end

function map_segments!(segments, grid, diagonal=false)
  for i in 1:size(segments)[1]
    x1, y1, x2, y2 = segments[i, :]
    if x1 == x2
      step = y1 < y2 ? 1 : -1
      for y in y1:step:y2
        grid[x1, y] += 1
      end
    elseif y1 == y2
      step = x1 < x2 ? 1 : -1
      for x in x1:step:x2
        grid[x, y1] += 1
      end
    elseif diagonal
      x_sign = x2 > x1 ? 1 : -1
      y_sign = y2 > y1 ? 1 : -1
      @assert abs(x2 -x1) == abs(y2 - y1)
      for i in 0:abs(x2 - x1)
        grid[x1 + x_sign*i, y1 + y_sign*i] += 1
      end
    end
  end
end

function problem1(segments)
  grid = create_grid(segments)
  map_segments!(segments,grid)
  sum(Int64.(grid .> 1))
end

function problem2(segments)
  grid = create_grid(segments)
  map_segments!(segments,grid, true)
  sum(Int64.(grid .> 1))
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  @assert problem1(A) == 5
  @assert problem2(A) == 12


  A = load("input.txt")
  println(problem1(A))
  println(problem2(A))
end
