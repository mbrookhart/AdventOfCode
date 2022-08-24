struct Policy
  min::Int64
  max::Int64
  char::Char
end

function Policy(line)
  l,r = split(line, " ")
  min,max = parse.(Int64, split(l, "-"))
  return Policy(min, max, first(r))
end

struct Password
  policy::Policy
  value::String
end

function Password(line)
  l,r = split(line, ":")
  return Password(Policy(l), strip(r))
end

function validate1(password::Password)
  N = count(password.policy.char, password.value)
  password.policy.min <= N && N <= password.policy.max
end

function validate2(password::Password)
  first = password.value[password.policy.min] == password.policy.char
  second = password.value[password.policy.max] == password.policy.char
  (first || second) && !(first && second)
end

function load(file)
  Password.(readlines(file))
end


function problem1(data)
  sum(validate1.(data))
end

function problem2(data)
  sum(validate2.(data))
end

if abspath(PROGRAM_FILE) == @__FILE__
  data = load("test.txt")
  @assert problem1(data) == 2
  @assert problem2(data) == 1


  data = load("input.txt")
  println(problem1(data))
  println(problem2(data))
end

