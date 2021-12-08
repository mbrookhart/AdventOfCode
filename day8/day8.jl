function load(file)
  lines = readlines(file)
  tmp = String.(reduce(hcat,split.(lines," | ")))
  signal_patterns = split.(tmp[1,:], " ")
  output_values = split.(tmp[2,:], " ")
  return signal_patterns, output_values
end

#  1111
# 2    3
# 2    3
#  4444
# 5    6
# 5    6
#  7777

function chars_in_string(a,b)
  # determines if all of the characters in string b
  # are also present in string a
  mapreduce(c->c in a, &, collect(b))
end


function map_patterns_to_number(pattern, value)
  # These are manual rules to figure out what numbers are what by comparing what
  # lines in the following illustration they share
  #
  #  1111
  # 2    3
  # 2    3
  #  4444
  # 5    6
  # 5    6
  #  7777
  #
  # the lines the numbers use are as follows:
  #zero = [1, 2, 3, 5, 6, 7]
  #one = [3, 6]
  #two = [1, 3, 4, 5, 7]
  #three = [1, 3, 4, 6, 7]
  #four = [2, 3, 4, 6]
  #five = [1, 2, 4, 6, 7]
  #six = [1, 2, 4, 5, 6, 7]
  #seven = [1, 3, 6]
  #eight = [1, 2, 3, 4, 5, 6, 7]
  #nine = [1, 2, 3, 4, 6, 7]
  lengths = length.(pattern)
  # Unique numbers
  one = String(pattern[findall(x->x==2, lengths)][1])
  seven = String(pattern[findall(x->x==3, lengths)][1])
  four = String(pattern[findall(x->x==4, lengths)][1])
  eight = String(pattern[findall(x->x==7, lengths)][1])
  # Numbers that use 6 lines
  len_6s = findall(x->x==6, lengths)
  nine = ""
  zero = ""
  six = ""
  for l in len_6s
    found9 = mapreduce(c->c in pattern[l], &, collect(four))
    if chars_in_string(pattern[l], four)
      nine = String(pattern[l])
    elseif chars_in_string(pattern[l], one)
      zero = String(pattern[l])
    else
      six = String(pattern[l])
    end
  end
  # numbers that use 4 lines
  len_5s = findall(x->x==5, lengths)
  two = ""
  three = ""
  five = ""
  for l in len_5s
    if chars_in_string(pattern[l], one)
      three = String(pattern[l])
    elseif chars_in_string(nine, pattern[l])
      five = String(pattern[l])
    else
      two = String(pattern[l])
    end
  end
  dict = Dict(zero=>'0',
              one=>'1',
              two=>'2',
              three=>'3',
              four=>'4',
              five=>'5',
              six=>'6',
              seven=>'7',
              eight=>'8',
              nine=>'9')
  parse(Int64, String(map(x->dict[x], value)))
end

function problem1(patterns, values)
  total = 0
  for value in values
    for word in value
      l = length(word)
      if l in [2, 3, 4, 7]
        total += 1
      end
    end
  end
  total
end

function sort_string(string)
  String(sort(collect(string)))
end

function problem2(patterns, values)
  total = 0
  for i in 1:length(patterns)
    # Sort the strings before mapping them so permutations don't cause pain
    total += map_patterns_to_number(sort_string.(patterns[i]), 
                                    sort_string.(values[i]))
  end
  total
end

if abspath(PROGRAM_FILE) == @__FILE__
  patterns, values = load("test.txt")
  @assert problem1(patterns, values) == 26
  @assert problem2(patterns, values) == 61229

  patterns, values = load("input.txt")
  println(problem1(patterns, values))
  println(problem2(patterns, values))
end
