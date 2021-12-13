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

function traverse(graph, visit_count, inputs::Array{String, 1}; kwargs...)
  sum = 0
  double_visit = nothing
  kw_dict = Dict(kwargs...)
  for input in inputs
    if graph[input].big | (visit_count[input] < 1)
      sum += find_path!(graph, input, copy(visit_count); kwargs...)
    elseif haskey(kw_dict, :double_visit)
      if (!kw_dict[:double_visit] & (input != "start") & (input != "end"))
        sum += find_path!(graph, input, copy(visit_count); double_visit=true)
      end
    end
  end
  sum
end

function bidir_traverse(graph, name, visit_count; kwargs...)
  sum = 0
  # bidrectional traversal
  if name == "start"
    sum = 1
  else
    sum += traverse(graph, visit_count, graph[name].inputs; kwargs...)
    sum += traverse(graph, visit_count, graph[name].outputs; kwargs...)
  end
  sum
end

function find_path!(graph, name, visit_count; kwargs...)
  visit_count[name] += 1
  bidir_traverse(graph, name, visit_count; kwargs...)  
end
  
function problem1(A)
  visit_count = Dict{String, Int64}(key=>0 for key in keys(A))
  find_path!(A, "end", visit_count)
end

function problem2(A)
  visit_count = Dict{String, Int64}(key=>0 for key in keys(A))
  find_path!(A, "end", visit_count; double_visit=false)
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
