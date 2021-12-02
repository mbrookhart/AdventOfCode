include("../utils.jl")

function problem1(instructions)
  x = 0
  z = 0
  for (dir, val) in instructions
    if dir == "up"
      z -= val
    elseif dir == "down"
      z += val
    elseif dir == "forward"
      x += val
    else
      @assert(false, dir)
    end
  end
  x * z
end

function problem2(instructions)
  x = 0
  z = 0
  aim = 0
  for (dir, val) in instructions
    if dir == "up"
      aim -= val
    elseif dir == "down"
      aim += val
    elseif dir == "forward"
      z += aim * val
      x += val
    else
      @assert(false, dir)
    end
  end
  x * z
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = [
       ("forward", 5),
       ("down", 5),
       ("forward", 8),
       ("up", 3),
       ("down", 8),
       ("forward", 2)
      ]
  @assert(problem1(A) == 150)
  @assert(problem2(A) == 900)
  
  # Load the data and convert it to a stable type for speed
  tmp = open(readdlm, "input.txt")
  B = similar(A, 1000)
  for i in 1:size(tmp)[1]
    B[i] = (String(tmp[i, 1]), tmp[i, 2])
  end

  println(problem1(B))
  println(problem2(B))
end
