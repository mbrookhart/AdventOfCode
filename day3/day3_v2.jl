struct BitArray
  vals
  W
end

function read_bin_mat(file)
  A = readlines(file)
  W = length(A[1])
  A = parse.(Int64, A; base=2)
  BitArray(A, W)
end

function get_bit(val, pos)
  (val >> (pos - 1)) - ((val >> pos) << 1)
end          

function most_common_value(bits)
  Int64(sum(bits) >= (length(bits)/2))
end

function least_common_value(bits)
  Int64(most_common_value(bits) == 0)
end

function bits_to_int(vec)
  parse(Int64, String(Char.(vec .+ '0')); base=2)
end

function problem1(A)
  N = length(A.vals)
  gamma = Array{Int64}(undef,0)
  for j = 1:A.W
    push!(gamma, most_common_value(get_bit.(A.vals, j)))
  end
  reverse!(gamma)
  bits_to_int(gamma) * bits_to_int(Int64.(gamma .== 0))
end

function reduce_list(A, func)
  out = copy(A.vals)
  j = A.W
  while (length(out) > 1) && (j > 0)
    bits = get_bit.(out, j)
    val = func(bits)
    keep = bits .== val
    if sum(Int64.(keep)) > 0
      out = out[bits .== val]
    end
    j -= 1
  end
  out
end

function problem2(A)
  O2 = reduce_list(A, most_common_value)
  CO2 = reduce_list(A, least_common_value)
  O2[1] * CO2[1]
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = read_bin_mat("test.txt")
  @assert problem1(A) == 198
  @assert problem2(A) == 230

  B = read_bin_mat("input.txt")
  println(problem1(B))
  println(problem2(B))
end
