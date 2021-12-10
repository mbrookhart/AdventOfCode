function load(file)
  readlines(file)
end

const start_stop = Dict('('=>')', '['=>']','{'=>'}','<'=>'>')
const score = Dict(')'=>3, ']'=>57,'}'=>1197,'>'=>25137)

function problem1(A)
  illegal = Array{Char, 1}(undef, 0)
  for line in A
    stack = Array{Char, 1}(undef, 0)
    for i in 1:length(line)
      if line[i] in keys(start_stop)
        push!(stack, line[i])
      elseif line[i] == start_stop[last(stack)]
        pop!(stack)
      else
        push!(illegal, line[i])
        break
      end
    end
  end
  sum(map(x->score[x], illegal))
end

const complete_score = Dict(')'=>1, ']'=>2,'}'=>3,'>'=>4)
function problem2(A)
  scores = Array{Int64, 1}(undef, 0)
  for line in A
    stack = Array{Char, 1}(undef, 0)
    incomplete = false
    for i in 1:length(line)
      if line[i] in keys(start_stop)
        push!(stack, line[i])
      elseif line[i] == start_stop[last(stack)]
        pop!(stack)
      else
        incomplete = true
        break
      end
    end
    if !incomplete
      tmp_score = 0
      while length(stack) > 0
        tmp_score *= 5
        tmp_score += complete_score[start_stop[pop!(stack)]]
      end
      push!(scores, tmp_score)
    end
  end
  sort(scores)[length(scores) ÷ 2 + 1]
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  @assert problem1(A) == 26397
  @assert problem2(A) == 288957

  B = load("input.txt")
  println(problem1(B))
  println(problem2(B))
end
