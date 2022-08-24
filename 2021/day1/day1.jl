include("../utils.jl")

function problem_one(A)
  sum(diff(A) .> 0)
end

function problem_two(A)
  W = 3
  B = [sum(A[i:i+W-1]) for i in 1:length(A) - (W-1)]
  problem_one(B)
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = [199, 200, 208, 210, 200, 207, 240, 269, 260, 263]

  @assert(problem_one(A) == 7)
  @assert(problem_two(A) == 5)

  B = round.(Int, read_col_vector("day1_problem1.input"))
  println(problem_one(B))
  println(problem_two(B))
end
