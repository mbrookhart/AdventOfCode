module day08

using InlineTest

const TEST_STRING = """30373
25512
65332
33549
35390"""


@testset "day08" begin
  @test solve(IOBuffer(TEST_STRING)) == (
    21,
    8
  )
end


function load(file)
  lines = readlines(file)
  N = length(lines)
  M = length(lines[1])
  A = Matrix{Int64}(undef, N,M)
  for i in 1:N
    A[i, :] = parse.(Int64, collect(lines[i]))
  end
  A
end

function find_visible(vec)
  max = -1
  visible = zeros(Bool, length(vec)) 
  for i in 1:length(vec)
    if vec[i] > max
      visible[i] = true
      max = vec[i]
    end
  end
  visible
end

function problem1(A)
  N, M = size(A)
  visible = zeros(Bool, size(A))
  for i in 1:N 
    visible[i,:] .|= find_visible(A[i,:])
    visible[i,:] .|= reverse(find_visible(reverse(A[i,:])))
  end
  for j in 1:M 
    visible[:,j] .|= find_visible(A[:,j])
    visible[:,j] .|= reverse(find_visible(reverse(A[:,j])))
  end
  sum(Int64.(visible))
end

function scenic_score(A, ii, jj)
  N, M = size(A)
  scores = [0,0,0,0]
  val = A[ii, jj]
  for i = ii+1:N
    if A[i,jj] >= val || i == N
      scores[1] = i - ii
      break
    end
  end
  for i = ii-1:-1:1
    if A[i,jj] >= val || i == 1
      scores[2] = ii - i
      break
    end
  end
  for j = jj+1:M
    if A[ii,j] >= val || j == M
      scores[3] = j - jj
      break
    end
  end
  for j = jj-1:-1:1
    if A[ii,j] >= val || j == 1
      scores[4] = jj - j
      break
    end
  end
  prod(scores)
end

function problem2(A)
  scores = zeros(Int64, size(A))
  for j in 1:size(A)[2], i in 1:size(A)[1]
    scores[i,j] = scenic_score(A, i, j)
  end
  maximum(scores)
end

function solve(io::IO)
  A = load(io)
  (
    problem1(A), 
    problem2(A)
  )
end

end