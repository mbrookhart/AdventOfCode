module day23

using InlineTest
using Match
using DataStructures

@testset "day23" begin
  @test solve(open("../data/day23.test")) == (
    110,
    20
  )
end

struct Elf
  x::Int
  y::Int
end


function grid_to_elves(grid)
  [Elf(m[1], m[2]) for m in findall(x->x=='#', grid)]
end

function elves_to_grid(elves)
  min_x = mapreduce(e->e.x, min, elves)
  max_x = mapreduce(e->e.x, max, elves)
  min_y = mapreduce(e->e.y, min, elves)
  max_y = mapreduce(e->e.y, max, elves)
  grid = Matrix{Char}(undef, max_x - min_x + 1, max_y - min_y + 1)
  grid .= '.'
  for elf in elves
    grid[elf.x - min_x + 1, elf.y - min_y + 1] = '#'
  end
  grid
end

function load(file)
  mapreduce(permutedims,vcat,collect.(readlines(file)))
end

move_north(grid, elf) = all(grid[elf.x - 1, elf.y - 1:elf.y + 1] .== '.') ? 
                        Elf(elf.x - 1, elf.y) : nothing
move_south(grid, elf) = all(grid[elf.x + 1, elf.y - 1:elf.y + 1] .== '.') ? 
                        Elf(elf.x + 1, elf.y) : nothing
move_west(grid, elf) = all(grid[elf.x - 1:elf.x + 1, elf.y - 1] .== '.') ?
                        Elf(elf.x, elf.y - 1) : nothing
move_east(grid, elf) = all(grid[elf.x - 1:elf.x + 1, elf.y + 1] .== '.') ?
                        Elf(elf.x, elf.y + 1) : nothing

function move(grid, num)
  funcs = [move_north, move_south, move_west, move_east]
  start = mod(num - 1, 4) + 1
  funcs = vcat(funcs[start:end], funcs[1:start-1])
  N, M = size(grid)
  tmp = Matrix{Char}(undef, N+2, M+2)
  tmp .= '.'
  tmp[2:end-1, 2:end-1] = grid
  grid = tmp
  elves = grid_to_elves(grid)
  new_positions = Vector{Tuple{Int, Elf}}()
  out = Vector{Elf}()
  for i in 1:length(elves)
    elf = elves[i]
    if sum(grid[elf.x-1:elf.x+1, elf.y-1:elf.y+1] .== '.') == 8
      push!(out, elf)
      continue
    end
    found = false
    for func in funcs
      new = func(grid, elf)
      if !found && new != nothing
        push!(new_positions, (i, new))
        found = true
      end
    end
    if !found
      push!(out, elf)
    end
  end
  count = DefaultDict{Elf, Int}(0)
  for (i, elf) in new_positions
    count[elf] += 1
  end
  for i in 1:length(new_positions)
    if count[new_positions[i][2]] == 1
      push!(out, new_positions[i][2])
    else
      push!(out, elves[new_positions[i][1]])
    end
  end
  #println(length(out), " ", length(elves))
  @assert length(out) == length(elves)
  elves_to_grid(out)
end

function print_grid(grid)
  println(size(grid))
  for i in 1:size(grid)[1]
    println(String(grid[i,:]))
  end
  println()
end

function problem1(data)
  for i in 1:10
    data = move(data, i)
  end
  sum(data .== '.')
end

function problem2(data)
  i = 1
  while true
    tmp = move(data, i)
    if size(tmp) == size(data) && all(tmp .== data)
      return i
    end
    data = tmp
    i += 1 
  end

end

function solve(io::IO)
  data = load(io)
  (
    problem1(deepcopy(data)),
    problem2(deepcopy(data))
  )
end

end