function simulate_trajectory(v_x, v_y, target_area)
  x0, x1, y0, y1 = target_area
  x = [0]
  y = [0]
  while true
    push!(x, last(x) + v_x)
    push!(y, last(y) + v_y)

    v_x -= sign(v_x)
    v_y -= 1
    
    if v_y < 0 && last(y) < y0 && last(y) < y1 
      break
    end
  end
  x, y
end

function hit_target(x, y, target_area)
  x0, x1, y0, y1 = target_area
  mapreduce(pos -> (x0 <= pos[1]) && (pos[1] <= x1) && (y0 <= pos[2]) && (pos[2] <= y1), |, zip(x, y))
end


function problem1(target_area)
  x0, x1, y0, y1 = target_area
  max_y = Array{Int64, 1}(undef, 0)
  for v_x in 1:100
    for v_y in 1:200
      xs, ys = simulate_trajectory(v_x, v_y, target_area)
      if hit_target(xs, ys, target_area)
        push!(max_y, maximum(ys))
      end
    end
  end
  maximum(max_y)
end


function problem2(target_area)
  x0, x1, y0, y1 = target_area
  count = 0
  for v_x in -200:200
    for v_y in -200:200
      xs, ys = simulate_trajectory(v_x, v_y, target_area)
      if hit_target(xs, ys, target_area)
        count += 1
      end
    end
  end
  count
end


if abspath(PROGRAM_FILE) == @__FILE__
  @assert problem1([20, 30, -10, -5]) == 45
  @assert problem2([20, 30, -10, -5]) == 112

  println(problem1([150, 171, -129, -70]))
  println(problem2([150, 171, -129, -70]))
end
