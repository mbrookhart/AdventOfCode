import Base.keys
import Base.push!

struct Polymer
  pairs::Dict{String, Int64}
end

function Polymer(a::String)
  p = Polymer(Dict{String, Int64}())
  chars = collect(a)
  for i in 1:(length(a) - 1)
    add_value!(p, String(chars[i:i+1]), 1)
  end
  p
end

function add_value!(p::Polymer, s::String, v::Int64)
  if !(s in keys(p))
    p.pairs[s] = 0
  end
  p.pairs[s] += v
end

function keys(p::Polymer)
  keys(p.pairs)
end

function count(p::Polymer, template)
  counts = Polymer("")
  for key in keys(p)
    add_value!(counts, String([key[1]]), p.pairs[key])
    add_value!(counts, String([key[2]]), p.pairs[key])
  end
  for key in keys(counts)
    if (collect(key)[1] == template[1]) | (collect(key)[1] == last(template))
      counts.pairs[key] += 1
    end
    counts.pairs[key] /= 2
  end
  counts.pairs
end

function load(file)
  lines = readlines(file)
  template = ""
  rules = Dict{String, Char}()
  found_empty = false
  for i in 1:length(lines)
    if lines[i] == ""
      found_empty = true
    elseif found_empty
      rule, val = split(lines[i]," -> ")
      rules[rule] = collect(val)[1]
    else
      template = lines[i]
    end
  end
  rules, template
end

function step(p::Polymer, rules)
  out = Polymer("")
  for key in keys(p)
    c = rules[key]
    k = collect(key)
    add_value!(out, String([key[1], c]), p.pairs[key])
    add_value!(out, String([c, key[2]]), p.pairs[key])
  end
  out
end

function problem(A, n)
  rules, template = deepcopy(A)
  p = Polymer(template)
  for i in 1:n
    p = step(p, rules)
  end
  counts = count(p, template)
  maximum(values(counts)) - minimum(values(counts))
end

function problem1(A)
  problem(A, 10)
end

function problem2(A)
  problem(A, 40)
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test1.txt")
  println(problem1(A))
  @assert problem1(A) == 1588
  @assert problem2(A) == 2188189693529

  
  B = load("input.txt")
  println(problem1(B))
  println(problem2(B))
end
