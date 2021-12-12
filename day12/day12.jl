struct Node
  name::String 
  inputs::Array{String, 1} 
  outputs::Array{String, 1} 
  big::Bool
end

function Node(name)
  Node(name, [], [], all(uppercase(name).== name))
end

function load(file)
  lines = readlines(file)
  graph = Dict{String, Node}()
  for i in 1:length(lines)
    edge = String.(split(lines[i],"-"))
    for e in edge
      if !(e in keys(graph))
        graph[e] = Node(e)
      end
    end
    push!(graph[edge[2]].inputs, edge[1])
    push!(graph[edge[1]].outputs, edge[2])
  end
  graph
end

function find_path!(graph, name, visit_count)
  paths = Array{Array{String, 1}, 1}(undef,0)
  visit_count[name] += 1
  function traverse(inputs)
    for input in inputs
      if graph[input].big | (visit_count[input] < 1)
        tmp_count = copy(visit_count)
        new_paths = find_path!(graph, input, tmp_count)
        for new_path in new_paths
          push!(paths,[[name]; new_path])
        end
      end
    end
  end
  traverse(graph[name].inputs)
  # bidrectional traversal
  if name != "start"
    traverse(graph[name].outputs)
  elseif length(paths) == 0
    push!(paths, [name])
  end
  paths
end
  
function problem1(A)
  visit_count = Dict{String, Int64}(key=>0 for key in keys(A))
  paths = find_path!(A, "end", visit_count)
  length(paths)
end

function find_path!(graph, name, visit_count, double_visit)
  paths = Array{Array{String, 1}, 1}(undef,0)
  visit_count[name] += 1
  function traverse(inputs)
    for input in inputs
      if graph[input].big | (visit_count[input] < 1)
        tmp_count = copy(visit_count)
        new_paths = find_path!(graph, input, tmp_count, double_visit)
        for new_path in new_paths
          push!(paths,[[name]; new_path])
        end
      elseif (!double_visit & (input != "start") & (input != "end"))
        tmp_count = copy(visit_count)
        new_paths = find_path!(graph, input, tmp_count, true)
        for new_path in new_paths
          push!(paths,[[name]; new_path])
        end
      end
    end
  end
  traverse(graph[name].inputs)
  # bidrectional traversal
  if (name != "start")
    traverse(graph[name].outputs)
  elseif name == "start" && length(paths) == 0
    push!(paths, [name])
  end
  paths
end
  
function problem2(A)
  visit_count = Dict{String, Int64}(key=>0 for key in keys(A))
  
  paths = find_path!(A, "end", visit_count, false)
  length(paths)
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test1.txt")
  @assert problem1(A) == 10
  @assert problem2(A) == 36

  A = load("test2.txt")
  @assert problem1(A) == 19
  @assert problem2(A) == 103
  
  A = load("test3.txt")
  @assert problem1(A) == 226
  @assert problem2(A) == 3509
  
  B = load("input.txt")
  println(problem1(B))
  println(problem2(B))
end
