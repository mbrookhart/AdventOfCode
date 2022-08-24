using DataStructures

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

function Astar(A)
  N, M = size(A)
  inbounds = x -> (x[1] >= 1) & (x[1] <= N) & (x[2] >= 1) & (x[2] <= N)
  start = [1, 1]
  goal = [N, M]
  queue = PriorityQueue{Array{Int64, 1}, Int64}()
  enqueue!(queue, start, 0)
  came_from = Dict{Array{Int64, 1}, Array{Int64, 1}}()
  cost_so_far = Dict{Array{Int64, 1}, Int64}() 
  came_from[start] = [0, 0]
  cost_so_far[start] = 0
  heuristic = (goal, next) -> sum(abs.(goal .+ next))
  while length(queue) > 0
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
        priority = new_cost + heuristic(goal, next)
        if next in keys(queue) 
          if queue[next] > priority
            queue[next] = priority
          end
        else 
          enqueue!(queue, next, priority)
        end
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
