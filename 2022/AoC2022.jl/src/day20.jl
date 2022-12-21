module day20

using InlineTest

@testset "day20" begin
  @test solve(open("../data/day20.test")) == (
    3,
    1623178306
  )
end

cycle_index(i, N) = mod(i-1, N) + 1


function load(file)
  A = parse.(Int, readlines(file))
  [(i, A[i]) for i in 1:length(A)]
end

function mix!(data, d, i)
  pair = data[i]
  val = pair[2]
  pos = findfirst(x->x==pair, d)[1]
  new_pos = cycle_index(pos + val, length(data) - 1)
  deleteat!(d, pos)
  insert!(d, new_pos, pair)
end


function mix(data, d)
  for i in 1:length(data)
    mix!(data, d, i)
  end
  d
end

function score(d)
  zero = findfirst(x->x[2] == 0, d)[1]
  s = 0
  for i in 1:3
    t = d[cycle_index(zero + 1000*i, length(d))][2]
    s += t
  end
  s
end

function problem1(data)
  score(mix(data, deepcopy(data)))
end

function problem2(data)
  data = [(i, v*811589153) for (i,v) in data]
  d = deepcopy(data)
  for i in 1:10
    d = mix(data, d)
  end
  score(d)
end

function solve(io::IO)
  A = load(io)
  (
    problem1(deepcopy(A)),
    problem2(deepcopy(A))
  )
end

end