function get_limits(instructions)
  xs = sort(mapreduce(i->[i.x1, i.x2 + 1], vcat, instructions))
  ys = sort(mapreduce(i->[i.y1, i.y2 + 1], vcat, instructions))
  zs = sort(mapreduce(i->[i.z1, i.z2 + 1], vcat, instructions))
  unique(xs), unique(ys), unique(zs)
end

function make_cubes(xs, ys, zs)
  cubes = zeros(Int64, length(xs), length(ys), length(zs))
  x_indices = Dict(xs .=> 1:length(xs))
  y_indices = Dict(ys .=> 1:length(ys))
  z_indices = Dict(zs .=> 1:length(zs))
  cubes, x_indices, y_indices, z_indices
end

function run_sim(instructions)
  xs, ys, zs = get_limits(instructions)
  cubes, x_ind, y_ind, z_ind = make_cubes(xs, ys, zs)
  for i in instructions
    for z in z_ind[i.z1]:(z_ind[i.z2 + 1] - 1), y in y_ind[i.y1]:(y_ind[i.y2 + 1] - 1), x in x_ind[i.x1]:(x_ind[i.x2 + 1] - 1)
      cubes[x, y, z] = i.on
    end
  end
  total = 0
  for z in 1:size(cubes)[3], y in 1:size(cubes)[2], x in 1:size(cubes)[1]
    if cubes[x, y, z] == 1
      total += (xs[x + 1] - xs[x]) * (ys[y + 1] - ys[y]) * (zs[z + 1] - zs[z]) 
    end
  end
  total
end

function problem1(instructions)
  run_sim(filter(i->i.x1 >= -50 && i.x2 <= 50 && i.y1 >= -50 && i.y2 <= 50 && i.z1 >= -50 && i.z2 <= 50, instructions))
end


function problem2(instructions)
  run_sim(instructions)
end

struct Instruction{T}
  on::T
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
    on = Int64(tmp[1] == "on")
    x, y, z = split(tmp[2], ",")
    x1, x2 = parse.(Int64, split(split(x, "=")[2], ".."))
    y1, y2 = parse.(Int64, split(split(y, "=")[2], ".."))
    z1, z2 = parse.(Int64, split(split(z, "=")[2], ".."))
    push!(out, Instruction(on, x1, x2, y1, y2, z1, z2))
  end
  out
end

using Profile
if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  @assert problem1(A) == 590784
  A = load("test2.txt")
  @assert problem2(A) == 2758514936282235

  A = load("input.txt")
  println(problem1(A))
  println(problem2(A))
end
