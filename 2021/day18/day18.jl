struct Leaf
  x::Int64
end

struct Node
  l::Union{Node, Leaf}
  r::Union{Node, Leaf}
end

function Node(x::Int64)
  Leaf(x)
end

function Node(A::AbstractVector)
  Node(Node(A[1]), Node(A[2]))
end

function show(A::Leaf)
  string(A.x)
end

function show(A::Node)
  s = "["
  s *= show(A.l)
  s *= ","
  s *= show(A.r)
  s * "]"
end

function add(l::Union{Node, Leaf}, r::Union{Node, Leaf})
  Node(l, r)
end

function split(A::Leaf, already_split = false)
  if A.x > 9
    l = A.x ÷ 2
    r = A.x - l
    return Node(Leaf(l), Leaf(r)), true
  end
  A, false
end

function split(A::Node, already_split = false)
  l, s1 = split(A.l, already_split)
  r = A.r
  s2 = false
  if !s1
    r, s2 = split(r)
  end
  add(l, r), s1 | s2
end

function magnitude(x::Leaf)
  x.x
end
  
function magnitude(A::Node)
  3 * magnitude(A.l) + 2 * magnitude(A.r)
end

function find_exploding_node(A::Leaf, depth = 0)
  nothing
end

function find_exploding_node(A::Node, depth = 0)
  if depth == 4
    return A
  else
    l = find_exploding_node(A.l, depth + 1)
    if l != nothing
      return l
    else
      return find_exploding_node(A.r, depth + 1)
    end
  end
end

function sort(A::Leaf, depth)
  out = Array{Tuple{Union{Node, Leaf}, Int64}, 1}(undef, 0)
  push!(out, (A, depth))
  out
end

function sort(A::Node, depth = 0)
  [sort(A.l, depth + 1); [(A, depth)]; sort(A.r, depth + 1)]
end

function rewrite(A::Leaf, i, rules)
  i += 1
  if i in keys(rules)
    return rules[i], i
  end
  A, i
end

function rewrite(A::Node, i, rules)
  l,i = rewrite(A.l, i, rules)
  i += 1
  if i in keys(rules)
    return rules[i], i + 1
  end
  r, i = rewrite(A.r, i, rules)
  Node(l, r), i
end

function explode(A::Node)
  sorted = sort(A)
  exploding_node = find_exploding_node(A)
  if exploding_node != nothing
    rules = Dict{Int64, Leaf}()
    for i in 1:length(sorted)
      if sorted[i][1] == exploding_node && sorted[i][2] == 4
        rules[i] = Leaf(0)
        for j in i+2:length(sorted)
          if sorted[j][1] isa Leaf
            rules[j] = Leaf(sorted[j][1].x + exploding_node.r.x)
            break
          end
        end
        for j in i-2:-1:1
          if sorted[j][1] isa Leaf
            rules[j] = Leaf(sorted[j][1].x + exploding_node.l.x)
            break
          end
        end
        break
      end
    end
    return rewrite(A, 0, rules)[1]
  end
  A
end

function reduce(A::Node)
  prev = ""
  current = A
  while !(current == prev)
    prev = current
    current = explode(current)
    if prev == current
      current = split(current)[1]
    end
  end
  current
end

@assert add(Node([1,2]), Node([[3,4],5])) == Node([[1,2],[[3,4],5]])

@assert split(Node([[[[0,7],4],[15,[0,13]]],[1,1]]))[1] == Node([[[[0,7],4],[[7,8],[0,13]]],[1,1]])
@assert split(Node([[[[0,7],4],[[7,8],[0,13]]],[1,1]]))[1] == Node([[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]])

@assert magnitude(Node([[1,2],[[3,4],5]])) == 143
@assert magnitude(Node([[[[0,7],4],[[7,8],[6,0]]],[8,1]])) == 1384
@assert magnitude(Node([[[[1,1],[2,2]],[3,3]],[4,4]])) == 445
@assert magnitude(Node([[[[3,0],[5,3]],[4,4]],[5,5]])) == 791
@assert magnitude(Node([[[[5,0],[7,4]],[5,5]],[6,6]])) == 1137
@assert magnitude(Node([[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]])) == 3488

@assert explode(Node([[[[[9,8],1],2],3],4])) == Node([[[[0,9],2],3],4])
@assert explode(Node([7,[6,[5,[4,[3,2]]]]])) == Node([7,[6,[5,[7,0]]]])
@assert explode(Node([[6,[5,[4,[3,2]]]],1])) == Node([[6,[5,[7,0]]],3])
@assert explode(Node([[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]])) == Node([[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]])
@assert explode(Node([[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]])) == Node([[3,[2,[8,0]]],[9,[5,[7,0]]]])

@assert reduce(add(Node([[[[4,3],4],4],[7,[[8,4],9]]]), Node([1,1]))) == Node([[[[0,7],4],[[7,8],[6,0]]],[8,1]])
@assert reduce(add(
                   Node([[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]),
                   Node([7,[[[3,7],[4,3]],[[6,3],[8,8]]]]))
              ) == Node([[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]])

@assert reduce(add(
                   Node([[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]),
                   Node([[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]))
              ) == Node([[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]])
@assert reduce(add(
                   Node([[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]),
                   Node([[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]))
              ) == Node([[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]])
@assert reduce(add(
                   Node([[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]),
                   Node([7,[5,[[3,8],[1,4]]]]))
              ) == Node([[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]])
@assert reduce(add(
                   Node([[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]]),
                   Node([[2,[2,2]],[8,[8,1]]]))
              ) == Node([[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]])

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

function load(file)
  lines = readlines(file)
  map(x->Node(eval(Meta.parse(x))), lines)
end


if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  @assert problem1(A) == 4140
  @assert problem2(A) == 3993

  B = load("input.txt")
  println(problem1(B))
  println(problem2(B))
end
