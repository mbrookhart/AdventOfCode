function load(file)
  lines = readlines(file)
  N = length(lines)
  M = length(lines[1])
  A = Array{Int64}(undef, N, M)
  for i in 1:N
    for j in 1:M
      A[i,j] = parse(Int64, lines[i][j])
    end
  end
  A
end

mutable struct PQueue
  A::Dict{Int64, Array{Int64, 1}}
  priority::Dict{Int64, Int64}
  state::Int64
end

function PQueue()
  PQueue(Dict{Int64, Array{Int64, 1}}(), Dict{Int64, Int64}(), 0)
end

function enqueue!(q::PQueue, k::Array{Int64, 1}, v::Int64)
  q.A[q.state] = k
  q.priority[q.state] = v
  q.state += 1
end

function dequeue!(q::PQueue)
  minvalue, index = findmin(q.priority)
  pop!(q.priority, index)
  pop!(q.A, index)
end

function len(q::PQueue)
  length(q.A)
end

function Astar(A)
  N, M = size(A)
  inbounds = x -> (x[1] >= 1) & (x[1] <= N) & (x[2] >= 1) & (x[2] <= N)
  start = [1, 1]
  goal = [N, M]
  queue = PQueue()
  enqueue!(queue, start, 0)
  came_from = Dict{Array{Int64, 1}, Array{Int64, 1}}()
  cost_so_far = Dict{Array{Int64, 1}, Int64}() 
  came_from[start] = [0, 0]
  cost_so_far[start] = 0
  heuristic = (goal, next) -> sum(abs.(goal .+ next))
  while len(queue) > 0
    current = dequeue!(queue)
    if current == goal
      break
    end
    i, j = current
    neighbors = filter(inbounds, [[i, j - 1], [i, j + 1], [i - 1, j], [i + 1, j]])
    for next in neighbors
      new_cost = cost_so_far[current] + A[next...]
      if !(next in keys(cost_so_far)) || (new_cost < cost_so_far[next])
        cost_so_far[next] = new_cost
        enqueue!(queue, next, new_cost + heuristic(goal, next))
        came_from[next] = current
      end
    end
  end
  cost_so_far[goal]
end

function problem1(A)
  Astar(A)
end

function problem2(A)
  N, M = size(A)

  B = zeros(Int64, 5*N, 5*M)
  for jj in 1:5
    for j in 1:M
      for ii in 1:5
        for i in 1:M
          B[(ii - 1) * N + i, (jj - 1) * M + j] = A[i, j] + (ii - 1) + (jj - 1)
        end
      end
    end
  end
  while maximum(B) > 9
    B[B .> 9] .-= 9
  end
  Astar(B)
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  @assert problem1(A) == 40
  @assert problem2(A) == 315

  B = load("input.txt")
  println(problem1(B))
  println(problem2(B))
end
