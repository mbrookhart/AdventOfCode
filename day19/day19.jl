using Combinatorics, LinearAlgebra

mutable struct Scanner
  x::Int64
  y::Int64
  z::Int64
  x_dir::Int64
  y_dir::Int64
  z_dir::Int64
  beacons::Array{Int64, 2}
end

function load(file)
  lines = readlines(file)
  scanners = Array{Scanner, 1}(undef, 0)
  beacons = Array{Array{Int64, 1}}(undef, 0)
  for line in lines
    if occursin("scanner", line)
      beacons = Array{Array{Int64, 1}}(undef, 0)
    elseif line == ""
      push!(scanners, Scanner(0,0,0,1,2,3,hcat(beacons...)'))
    else
      push!(beacons, parse.(Int64, split(line, ",")))
    end
  end
  scanners
end

function sort_on_x(A)
  sortslices(A,dims=1,by=x->(x[1], x[2], x[3]),rev=false)
end

function rotate_beacons(beacons, x, y, z)
  B = zeros(Int64, size(beacons))
  B[:, 1] = sign(x) .* beacons[:, abs(x)]
  B[:, 2] = sign(y) .* beacons[:, abs(y)]
  B[:, 3] = sign(z) .* beacons[:, abs(z)]
  B 
end

function unit_vector(x)
  vec = zeros(Int64, 3)
  vec[abs(x)] = sign(x)
  vec
end

function right_hand(x, y, z)
  all(cross(unit_vector(x), unit_vector(y)) .== unit_vector(z))
end

function match_scanners(s1, s2)
  # assume s1 is in the right direction
  #lets assume x is always 1, because it breaks a repeated axis
  #if x = 1
  # y, z can be in (2, 3), (3, -2),  (-2, -3), (-3, 2)
  for axes in collect(permutations([1, 2, 3]))
    for x_dir in [-1, 1], y_dir in [-1, 1], z_dir in [-1, 1]
      x, y, z = axes
      x *= x_dir
      y *= y_dir
      z *= z_dir
      if !right_hand(x, y, z)
        continue
      end
      B = rotate_beacons(s2.beacons, x, y, z)
      O = Array{Array{Int64, 2}, 1}(undef, 0)
      for i in 1:size(s1.beacons)[1]
        push!(O, s1.beacons[i,:]' .- B)
      end
      O = sort_on_x(vcat(O...))
      for i in 1:size(O)[1] - 11
        if all(O[i,:] .== O[i + 11,:])
          return true, (O[i,:])..., x, y, z
        end
      end
    end
  end
  false, 0, 0, 0, 0, 0, 0
end

function update_scanner!(scanner, x, y, z, x_dir, y_dir, z_dir)
  scanner.x = x
  scanner.y = y
  scanner.z = z
  scanner.x_dir = x_dir
  scanner.y_dir = y_dir
  scanner.z_dir = z_dir
  B = rotate_beacons(scanner.beacons, x_dir, y_dir, z_dir)
  B[:, 1] .+= x
  B[:, 2] .+= y
  B[:, 3] .+= z
  scanner.beacons = B
end

function unique_beacons(scanners)
  unique = Array{Array{Int64, 1}, 1}(undef, 0)
  push!(unique, scanners[1].beacons[1, :])
  for scanner in scanners
    for i in 1:size(scanner.beacons)[1]
      for j in 1:size(unique)[1]
        if all(unique[j] .== scanner.beacons[i,:])
          @goto not_unique
        end
      end
      push!(unique, scanner.beacons[i, :])
      @label not_unique
    end
  end
  unique
end

function problem1(scanners)
  scanners=deepcopy(scanners)
  # Assume the first scanner is oriented such that x->x, y->y, z->z
  # and is located at x=0, y=0, z=0
  # Try to find the other scanners based on that
  # x, y, z = 1, 2, 3
  found = [false for i in 1:length(scanners)]
  tested = zeros(Int64, length(scanners), length(scanners))
  found[1] = true
  i = 0
  while i < 1000
    i += 1
    for i in 1:length(scanners)
      for j in 1:length(scanners)
        if tested[i,j] == 0 && !found[i] && found[j] 
          tested[i, j] = 1
          m = match_scanners(scanners[j], scanners[i])
          if m[1]
            found[i] = true
            update_scanner!(scanners[i], m[2:end]...)
            break
          end
        end
      end
    end
    if all(found)
      break
    end
  end
  length(unique_beacons(scanners)), scanners
end

function manhattan_distance(s1, s2)
  return abs(s1.x - s2.x) + abs(s1.y - s2.y) + abs(s1.z - s2.z)
end

function problem2(scanners)
  dist = Array{Int64, 1}(undef, 0)
  for i in 1:length(scanners), j in 1:length(scanners)
    push!(dist, manhattan_distance(scanners[i], scanners[j]))
  end
  maximum(dist)
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  N, B = problem1(A)
  @assert N == 79
  @assert problem2(B) == 3621

  A = load("input.txt")
  N, B = problem1(A)
  println(N)
  println(problem2(B))
end
