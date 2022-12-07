module day07

using InlineTest
using DataStructures

const TEST_STRING = """\$ cd /
\$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
\$ cd a
\$ ls
dir e
29116 f
2557 g
62596 h.lst
\$ cd e
\$ ls
584 i
\$ cd ..
\$ cd ..
\$ cd d
\$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k"""


@testset "day07" begin
  @test solve(IOBuffer(TEST_STRING)) == (
    95437,
    24933642
  )
end

struct File
  name::String
  filesize::Int
end

mutable struct Dir
  name::String
  parent::Union{Dir, Nothing}
  children::Vector{Union{Dir, File}}
end

function parse_graph(lines)
  root = Dir("/", nothing, [])
  current = root
  for line in lines
    if occursin("\$", line)
      # commands
      command = split(line)[2:end]
      if command[1] == "cd"
        if command[2] == "/"
          current = root
        elseif command[2] == ".."
          current = current.parent
        else
          current = [c for c in current.children if isa(c, Dir) && c.name == command[2]][1]
        end
      end
    else
      file = split(line)
      if file[1] == "dir"
          new_dir = Dir(file[2], current, [])
        push!(current.children, new_dir)
      else
        new_file = File(file[2], parse(Int,file[1]))
        push!(current.children, new_file)
      end
    end
  end
  root
end

function load(file)
  parse_graph(readlines(file))
end

function get_dir_size(f::File, visited::Dict{Dir, Int})
  f.filesize
end

function get_dir_size(d::Dir, visited::Dict{Dir, Int})
  total = 0
  if d in keys(visited)
    total = visited[d]
  else 
    for child in d.children
      total += get_dir_size(child, visited)
    end
    visited[d] = total
  end
  total
end

function find_size_directories(d::Dir)
  visited = Dict{Dir, Int}()
  get_dir_size(d, visited)
  visited
end

function problem1(root)
  sizes = find_size_directories(root)
  sum = 0
  for key in keys(sizes)
    if sizes[key] < 100000
      sum += sizes[key]
    end
  end
  sum 
end

function problem2(root)
  sizes = find_size_directories(root)
  total = 70000000
  needed = 30000000
  used = sizes[root]
  target = used - (total - needed)
  sorted_sizes = sort([v for v in values(sizes)])
  large_enough = sorted_sizes[sorted_sizes .>= target]
  large_enough[1]
end

function solve(io::IO)
  A = load(io)
  (
    problem1(A), 
    problem2(A)
  )
end

end