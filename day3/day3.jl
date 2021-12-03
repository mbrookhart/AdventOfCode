function read_bin_mat(file)
  A = readlines(file)
  N = size(A)[1]
  W = length(A[1])
  out = Array{Int64}(undef, N, W)
  for i in 1:N
    for j in 1:W
      out[i, j] = parse(Int64, A[i][j])
    end
  end
  out
end

function most_common_value(col, N)
  ones = 0
  zeros = 0
  for i in 1:N
    if col[i] == 1
      ones += 1
    else
      zeros += 1
    end
  end
  out = 0
  if ones >= zeros
    out = 1
  end
  out
end

function least_common_value(col, N)
  val = most_common_value(col, N)
  out = 0
  if val == 0
    out = 1
  end
  out
end

function problem1(A)
  N, W = size(A)
  gamma = collect(repeat("0", W))
  epsilon = collect(repeat("0", W))
  for j in 1:W
    val = most_common_value(A[:,j], N)
    if val == 1
      gamma[j] = '1'
    else
      epsilon[j] = '1'
    end
  end
  parse(Int64, String(gamma); base=2) * parse(Int64, String(epsilon); base=2)
end

function reduce_list(A, func)
  out = copy(A)
  N, W = size(A)
  j = 1
  while (size(out)[1] > 1) && (j <= W)
    ii = 0
    tmp = out*0
    val = func(out[:, j], size(out)[1])
    for jj in 1:W
      ii = 0
      for i in 1:size(out)[1]
        if out[i, j] == val
          ii += 1
          tmp[ii, jj] = out[i,jj]
        end
      end
    end
    j += 1
    out = tmp[1:ii,:]
  end
  out
end

function problem2(A)
  N, W = size(A)

  O2 = reduce_list(A, most_common_value)
  CO2 = reduce_list(A, least_common_value)
  parse(Int64, String(Char.(O2[1, :] .+ '0')); base=2) * parse(Int64, String(Char.(CO2[1, :] .+ '0')); base=2)
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = read_bin_mat("test.txt")
  @assert problem1(A) == 198
  @assert problem2(A) == 230

  B = read_bin_mat("input.txt")
  println(problem1(B))
  println(problem2(B))
end
