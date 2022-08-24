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

function flash!(A)
  A .+= 1
  N,M = size(A)
  inbounds = (x,y) -> (x >=1) & (x <= N) & (y>=1) & (y <= N)
  flashing = A .> 9
  flashed = flashing .& false
  while sum(flashing) > 0
    for j in 1:M
      for i in 1:N
        if flashing[i,j]
          for jj in -1:1
            for ii in -1:1
              if inbounds(i+ii, j+jj)
                A[i + ii, j + jj] += 1
              end
            end
          end
        end
      end
    end
    flashed = flashed .| flashing
    flashing = (A .> 9) .& (.!flashed)
  end
  A[flashed] .= 0
  sum(flashed)
end

function problem1(A)
  A = deepcopy(A)
  sum = 0
  for i in 1:100
    sum += flash!(A)
  end
  sum
end

function problem2(A)
  A = deepcopy(A)
  N, M = size(A)
  i = 0
  while flash!(A) != N*M
    i += 1
  end
  i + 1
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  @assert problem1(A) == 1656
  @assert problem2(A) == 195

  B = load("input.txt")
  println(problem1(B))
  println(problem2(B))
end
