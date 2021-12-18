using DataStructures

function load(file)
  lines = readlines(file)
  map(x->eval(Meta.parse(x)), lines)
end

function add(A, B)
  [A, B]
end

@assert add([1,2], [[3,4],5]) == [[1,2],[[3,4],5]]

function split(A::Int64, already_split = false)
  if A > 9
    l = A ÷ 2
    r = A - l
    return [l, r], true
  end
  A, false
end

function split(A, already_split = false)
  l, s1 = split(A[1], already_split)
  r = A[2]
  s2 = false
  if !s1
    r, s2 = split(A[2])
  end
  add(l, r), s1 | s2
end

@assert split([[[[0,7],4],[15,[0,13]]],[1,1]])[1] == [[[[0,7],4],[[7,8],[0,13]]],[1,1]]
@assert split([[[[0,7],4],[[7,8],[0,13]]],[1,1]])[1] == [[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]

function add_right(A, r, i)
  for j in i+1:length(A)
    if !(A[j] in ['[',']',','])
      for k in j+1:length(A)
        if A[k] in ['[',']',',']
          return A[1:j-1] * string(r + parse(Int64, A[j:k-1])) * A[k:end]
        end
      end
    end
  end
  A
end

function add_left(A, l, i)
  for j = i-1:-1:1
    if !(A[j] in ['[',']',','])
      for k in j-1:-1:1
        if A[k] in ['[',']',',']
          return A[1:k] * string(l + parse(Int64, A[k+1:j])) * A[j+1:end]
        end
      end
    end
  end
  A
end

function explode(A::String)
  stack = Array{Char, 1}(undef, 0)
  depth = 0
  for i in 1:length(A)
    if A[i] == '['
      depth +=1
    elseif A[i] == ']'
      depth -= 1
    end
    if depth == 5
      n = findfirst(']', A[i:end])
      l, r = eval(Meta.parse(A[i:i + n - 1]))
      A = A[1:i-1] * "0" * A[i+n:end]
      A = add_right(A, r, i)
      A = add_left(A, l, i)
      break
    end
  end
  A
end

function show_vector_sans_type(v::AbstractVector)
  s = "["
  for (i, elt) in enumerate(v)
    if i > 1
      s *= ","
    end
    if elt isa AbstractVector
      s *= show_vector_sans_type(elt)
    else
      s *= string(elt)
    end
  end
  s * "]"
end

function explode(A, depth = 1)
  s = show_vector_sans_type(A)
  eval(Meta.parse(explode(s)))
end

@assert explode([[[[[9,8],1],2],3],4]) == [[[[0,9],2],3],4]
@assert explode([7,[6,[5,[4,[3,2]]]]]) == [7,[6,[5,[7,0]]]]
@assert explode([[6,[5,[4,[3,2]]]],1]) == [[6,[5,[7,0]]],3]
@assert explode([[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]) == [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]
@assert explode([[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]) == [[3,[2,[8,0]]],[9,[5,[7,0]]]]

function magnitude(A::Int64)
  A
end
  
function magnitude(A)
  3 * magnitude(A[1]) + 2 * magnitude(A[2])
end

@assert magnitude([[1,2],[[3,4],5]]) == 143
@assert magnitude([[[[0,7],4],[[7,8],[6,0]]],[8,1]]) == 1384
@assert magnitude([[[[1,1],[2,2]],[3,3]],[4,4]]) == 445
@assert magnitude([[[[3,0],[5,3]],[4,4]],[5,5]]) == 791
@assert magnitude([[[[5,0],[7,4]],[5,5]],[6,6]]) == 1137
@assert magnitude([[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]) == 3488

function reduce(A)
  prev = ""
  current = A
  while current != prev
    prev = current
    current = explode(current)
    if prev == current
      current = split(current)[1]
    end
  end
  current
end

@assert reduce(add([[[[4,3],4],4],[7,[[8,4],9]]], [1,1])) == [[[[0,7],4],[[7,8],[6,0]]],[8,1]]

function problem1(A)
  out = A[1]
  for i in 2:length(A)
    out = reduce(add(out, A[i]))
  end
  magnitude(out)
end

function problem2(A)
  magnitudes = Array{Int64, 1}(undef, 0)
  for i in 1:length(A)
    for j in 1:length(A)
      push!(magnitudes, magnitude(reduce(add(A[i], A[j]))))
    end
  end
  maximum(magnitudes)
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  @assert problem1(A) == 4140
  @assert problem2(A) == 3993

  B = load("input.txt")
  println(problem1(B))
  println(problem2(B))
end
