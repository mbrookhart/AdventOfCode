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

function find_low(A)
  N, M = size(A)
  left = ones(Int64, N, M) .* 10
  right = ones(Int64, N, M) .* 10
  up = ones(Int64, N, M) .* 10
  down = ones(Int64, N, M) .* 10
  
  right[:, 2:M] = A[:, 1:M-1]
  left[:, 1:M-1] = A[:, 2:M]
  down[2:N, :] = A[1:N-1, :]
  up[1:N-1, :] = A[2:N, :]
  (left .> A) .& (right .> A) .& (up .> A) .& (down .> A)
end

function problem1(A)
  mask = find_low(A)
  risk = sum(A.*mask) + sum(mask)
  risk
end

function traverse!(graph, visited, i, j, N, M)
  sum = 1
  visited[i, j] = 1
  for jj in [-1, 1]
    if (((j + jj) >= 1) & ((j + jj) <= M))
      if ((visited[i, j+jj] == 0) & (graph[i, j+jj] == 1))
        sum += traverse!(graph, visited, i, j+jj, N, M)
      end
    end
  end
  for ii in [-1, 1]
    if (((i + ii) >= 1) & ((i + ii) <= N))
      if ((visited[i + ii, j] == 0) & (graph[i + ii , j] == 1))
        sum += traverse!(graph, visited, i + ii , j, N, M)
      end
    end
  end
  sum
end

function problem2(A)
  N, M = size(A)
  basins = Int64.(A .< 9)
  visited = zeros(Int64, size(A))
  sizes = Array{Int64}(undef, 0)
  while sum(basins .* (1 .- visited)) > 0
    for j in 1:M
      for i in 1:N
        if visited[i,j] == 0 && basins[i,j] == 1
          append!(sizes, traverse!(basins, visited, i, j, N, M))
        end
      end
    end
  end
  prod(sort(sizes, rev=true)[1:3])
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  @assert problem1(A) == 15
  @assert problem2(A) == 1134

  B = load("input.txt")
  println(problem1(B))
  println(problem2(B))
end
