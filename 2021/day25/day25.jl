

function step_right(grid)
  N, M = size(grid)
  new = deepcopy(grid)
  wrap = x -> x > M ? x - M : x
  for j in 1:M
    for i in 1:N
      new_j = wrap(j + 1)
      if grid[i, j] == '>' && grid[i, new_j] == '.'
        new[i, j] = '.'
        new[i, new_j] = '>'
      end
    end
  end
  new
end

function step_down(grid)
  N, M = size(grid)
  new = deepcopy(grid)
  wrap = x -> x > N ? x - N : x
  for j in 1:M
    for i in 1:N
      new_i = wrap(i + 1)
      if grid[i, j] == 'v' && grid[new_i, j] == '.'
        new[i, j] = '.'
        new[new_i, j] = 'v'
      end
    end
  end
  new
end


function problem1(grid)
  old_grid = deepcopy(grid)
  current_grid = deepcopy(grid)
  i = 0
  #println(i)
  #display(old_grid)
  #println()
  while i == 0 || !all(current_grid .== old_grid)
    old_grid = deepcopy(current_grid)
    current_grid = step_right(current_grid)
    current_grid = step_down(current_grid)
    #println(i)
    #display(current_grid)
    #println()
    i += 1
  end
  println(i)
  i
end

function load(file)
  lines = readlines(file)
  grid = Array{Char, 2}(undef, length(lines), length(lines[1]))
  for i in 1:length(lines)
    grid[i,:] = collect(lines[i])
  end
  grid
end


if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  @time @assert problem1(A) == 58
  #@assert problem2(A) == 2758514936282235
  
  A = load("input.txt")
  @time println(problem1(A))
  #println(problem2(A))
end
