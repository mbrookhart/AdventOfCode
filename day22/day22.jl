function get_limits(instructions)
  # We're going to generate a dense grid where each cell in the grid
  # represents a range of cubes in real space
  # This allows us to do the calculation in reduced memory
  # We add 1 to the ending point of each range becuase we
  # want each cell in our grid to represent x1->x2 inclusive,
  # and making the next cell start on x2 means we have double counting
  # of cells
  xs = sort(mapreduce(i->[i.x1, i.x2 + 1], vcat, instructions))
  ys = sort(mapreduce(i->[i.y1, i.y2 + 1], vcat, instructions))
  zs = sort(mapreduce(i->[i.z1, i.z2 + 1], vcat, instructions))
  unique(xs), unique(ys), unique(zs)
end

function make_cubes(xs, ys, zs)
  # Build up the dense map, and create dicts to easily find the index in the grid
  cubes = zeros(UInt8, length(xs), length(ys), length(zs))
  x_indices = Dict(xs .=> 1:length(xs))
  y_indices = Dict(ys .=> 1:length(ys))
  z_indices = Dict(zs .=> 1:length(zs))
  cubes, x_indices, y_indices, z_indices
end


function run_sim(instructions)
  xs, ys, zs = get_limits(instructions)
  cubes, x_ind, y_ind, z_ind = make_cubes(xs, ys, zs)
  # Apply the instructions
  for i in instructions
    cubes[x_ind[i.x1]:(x_ind[i.x2 + 1] - 1), y_ind[i.y1]:(y_ind[i.y2 + 1] - 1), z_ind[i.z1]:(z_ind[i.z2 + 1] - 1)] .= i.on
  end
  # perform the sum by multiplying the on/off state by the nubmer of cubes in each cell
  sum(cubes[1:end-1, 1:end-1, 1:end-1] .* (diff(xs) .* diff(ys)' .* reshape(diff(zs), 1, 1, :)))
end

function problem1(instructions)
  run_sim(filter(i->i.x1 >= -50 && i.x2 <= 50 && i.y1 >= -50 && i.y2 <= 50 && i.z1 >= -50 && i.z2 <= 50, instructions))
end


function problem2(instructions)
  run_sim(instructions)
end

struct Instruction{T}
  on::UInt8
  x1::T
  x2::T
  y1::T
  y2::T
  z1::T
  z2::T
end


function load(file)
  out = Array{Instruction, 1}(undef, 0)
  for line in readlines(file)
    tmp = split(line, " ")
    on = UInt8(tmp[1] == "on")
    x, y, z = split(tmp[2], ",")
    x1, x2 = parse.(Int32, split(split(x, "=")[2], ".."))
    y1, y2 = parse.(Int32, split(split(y, "=")[2], ".."))
    z1, z2 = parse.(Int32, split(split(z, "=")[2], ".."))
    push!(out, Instruction(on, x1, x2, y1, y2, z1, z2))
  end
  out
end

using Profile
using BenchmarkTools
if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  @assert problem1(A) == 590784
  A = load("test2.txt")
  @assert problem2(A) == 2758514936282235
  A = load("input.txt")
  println(problem1(A))
  #@profile problem2(A)
  #Profile.print(format=:flat)
  #display(@benchmark problem2(A))
  println(problem2(A))
end
