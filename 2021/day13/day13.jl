using SparseArrays

function load(file)
  lines = readlines(file)
  points = Array{Array{Int64, 1}, 1}(undef, 0)
  instructions = Array{Array{Int64, 1}, 1}(undef, 0)
  found_empty = false
  for i in 1:length(lines)
    if lines[i] == ""
      found_empty = true
    elseif found_empty
      instruction, val = split(lines[i],"=")
      axis = last(instruction) == 'y'
      push!(instructions, [Int64(axis), parse(Int64, val) + 1]) #julia is 1 indexed
    else
      push!(points, parse.(Int64, split(lines[i],",")))
    end
  end
  points = hcat(points...)' .+ 1 # julia is 1 indexed
  #we always fold in half, so base the inital size on the initial instructions
  N = 2 * filter(x->(x[1] == 0), instructions)[1][2] - 1
  M = 2 * filter(x->(x[1] == 1), instructions)[1][2] - 1
  grid = spzeros(N, M)
  for i in 1:size(points)[1]
    grid[points[i, 1], points[i, 2]] = 1
  end
  instructions, grid .> 0
end

function fold(grid, instruction)
  N, M = size(grid)
  if instruction[1] == 1
    grid = grid[:, 1:instruction[2] - 1] .| grid[:, M:-1:instruction[2] + 1,]
  else
    grid = grid[1:instruction[2] - 1,:] .| grid[N:-1:(instruction[2] + 1), :]
  end
  grid
end

function problem1(A)
  instructions, grid = deepcopy(A)
  grid = fold(grid, instructions[1])
  sum(Int64.(grid))
end

function problem2(A)
  instructions, grid = deepcopy(A)
  for instruction  in instructions
    grid = fold(grid, instruction)
  end
  Array(grid')
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test1.txt")
  @assert problem1(A) == 17
  #@assert problem2(A) == 36

  
  B = load("input.txt")
  println(problem1(B))
  display(problem2(B))
end
