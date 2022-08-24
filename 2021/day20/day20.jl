function enhance_image(instructions, image, default)
  N, M = size(image)
  out = zeros(Int64, N + 2, M + 2)
  inbounds = (x,y) -> (x >=1) & (x <= N) & (y>=1) & (y <= N)
  for j in 0:M+1
    for i in 0:N+1
      instruction = Array{Int64, 1}(undef, 0)
      for ii in -1:1
        for jj in -1:1
          if inbounds(i + ii, j + jj)
            push!(instruction, image[i + ii, j + jj])
          else
            push!(instruction, default)
          end
        end
      end
      instruction = parse(Int64, String(Char.('0' .+ instruction)), base=2)
      out[i + 1, j + 1] = instructions[instruction + 1]
    end
  end
  out
end

function show(A)
  A = A'
  for i in 1:size(A)[2]
    println(String(map(x->x == 0 ? '.' : '#', A[:, i])))
  end
end

function enhance(instructions, image, N)
  out = image
  default = 0
  for i in 1:N
    out = enhance_image(instructions, out, default)
    # This is the wierd bit, the value of the image trending toward infinitiy will
    # depend on what the instruction was for the value at the previous time step
    default = instructions[parse(Int64, String(Char.('0' .+ [default for i in 1:9])), base=2) + 1]
  end
  out
end

function problem1(instructions, image)
  out = enhance(instructions, image, 2)
  sum(out)
end

function problem2(instructions, image)
  out = enhance(instructions, image, 50)
  sum(out)
end

function load(file)
  lines = readlines(file)
  im_2_bin = x->x == '.' ? 0 : 1
  instructions = map(im_2_bin, collect(lines[1]))
  image = hcat(map(line->map(im_2_bin, collect(line)), lines[3:end])...)'
  instructions, image
end


if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  @assert problem1(A...) == 35
  @assert problem2(A...) == 3351

  B = load("input.txt")
  println(problem1(B...))
  println(problem2(B...))
end
