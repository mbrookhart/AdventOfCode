function load(file)
  parse.(Int64, readlines(file))
end

function binary_search(data, target, low, high)
  if low <= high
    mid = (low + high) ÷ 2
    if data[mid] == target
      return true
    elseif data[mid] < target
      return binary_search(data, target, mid + 1, high)
    else
      return binary_search(data, target, low, mid - 1)
    end
  end
  false
end

function problem1(data)
  N = length(data)
  for i in 1:N-1
    if binary_search(data, 2020 - data[i], i + 1, N)
      return data[i] * (2020 - data[i])
    end
  end
end

function problem2(data)
  N = length(data)
  for i=1:N-2
    for j=i:N-1
      if binary_search(data, 2020 - data[i] - data[j], j + 1, N)
        return data[i] * data[j] * (2020 - data[i] - data[j])
      end
    end
  end
end

if abspath(PROGRAM_FILE) == @__FILE__
  data = sort(load("test.txt"))
  @assert problem1(data) == 514579
  @assert problem2(data) == 241861950


  data = sort(load("input.txt"))
  println(problem1(data))
  println(problem2(data))
end

