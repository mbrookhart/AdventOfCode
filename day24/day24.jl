const instructions = Dict("add"=>'+', "mul"=>'*', "div"=>'/', "mod"=>'%', "eql"=>'=')
const register = Dict('w'=>1, 'x'=>2, 'y'=>3, 'z'=>4)

Inst = Union{Char, Int64}

function parse_value(x)::Inst
  length(x) > 1 ? parse(Int64, x) : isletter(collect(x)[1]) ? collect(x)[1] : parse(Int64, x)
end

function load(file)
  lines = readlines(file)
  out = Array{Array{Array{Inst, 1}, 1}}(undef, 0)
  tmp_inst = Array{Array{Inst, 1}, 1}(undef, 0)
  for line in lines
    tmp = split(line, " ")
    if length(tmp) == 2
      if length(tmp_inst) > 0
        push!(out, tmp_inst)
        tmp_inst = Array{Array{Inst, 1}}(undef, 0)
      end
      push!(tmp_inst, ['i', parse_value(tmp[2]), '_'])
    else
      left = tmp[2]
      right = tmp[3]
      push!(tmp_inst, [instructions[tmp[1]], parse_value(tmp[2]), parse_value(tmp[3])])
    end
  end
  push!(out, tmp_inst)
  out
end


function get_value(x::Char, state)
  state[register[x]]
end

function get_value(x::Int64, state)
  x
end

function execute_program(program, pos, i, z)
  state = [0,0,0,z]
  for line in program[pos]
    loc = register[line[2]] 
    if line[1] == 'i'
      state[loc] = i
    else
      op = line[1]
      a = get_value(line[2], state)
      b = get_value(line[3], state)
      if op == '+'
        state[loc] = a + b
      elseif op == '*'
        state[loc] = a * b
      elseif op == '/'
        state[loc] = a ÷ b
      elseif op == '%'
        state[loc] = a % b
      elseif op == '='
        state[loc] = a == b
      else
        @assert false
      end
    end
  end
  state[end]
end

function dfs!(memo, program, pos, z, digits)
  if haskey(memo, (pos, z))
    return memo[(pos, z)]
  end
  result = Array{Int64, 1}(undef, 0)
  for i in digits
    eresult = execute_program(program, pos, i, z)
    if pos == 14
      if eresult == 0
        push!(result, i)
        break
      end
    else
      rest = dfs!(memo, program, pos + 1, eresult, digits)
      if length(rest) != 0
        push!(result, i)
        append!(result, rest)
        break
      end
    end
  end
  memo[(pos, z)] = result
  result
end


function problem1(A)
  memo = Dict{Tuple{Int64, Int64}, Array{Int64, 1}}()
  dfs!(memo, A, 1, 0, Tuple(9:-1:1))
end

function problem2(A)
  memo = Dict{Tuple{Int64, Int64}, Array{Int64, 1}}()
  dfs!(memo, A, 1, 0, Tuple(1:9))
end

using Profile
if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  #@assert all(execute_program(A[1], [15]) .== [1, 1, 1, 1])
  A = load("input.txt")
  println(problem1(A))
  #@profile println(problem1(A))
  #Profile.print(format=:flat)
  println(problem2(A))
end
