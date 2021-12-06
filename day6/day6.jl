function load(file)
  parse.(Int64, split(readlines(file)[1], ","))
end

mutable struct School
  # fish_count stores how many fish are in each state
  # It should have length of 9, for 0-8 days until
  # reproduction
  fish_count::Array{Int64, 1}
end

function MakeSchool(fish)
  A = zeros(Int64, 9)
  for f in fish
    # f + 1 because julia is 1 indexed
    A[f + 1] += 1
  end
  School(A)
end

function evolve_school!(school::School)
  # Get the fish that are reproducing
  new_fish = school.fish_count[1]
  # step the other fish in time
  for i in 2:9
    school.fish_count[i - 1] = school.fish_count[i]
  end
  # populate the new fish
  school.fish_count[9] = new_fish
  # and the fish that just reproduced
  school.fish_count[7] += new_fish
end

function problem1(fish)
  school = MakeSchool(fish)
  for i in 1:80
    evolve_school!(school)
  end
  sum(school.fish_count)
end

function problem2(fish)
  school = MakeSchool(fish)
  for i in 1:256
    evolve_school!(school)
  end
  sum(school.fish_count)
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  @assert problem1(A) == 5934
  @assert problem2(A) == 26984457539

  A = load("input.txt")
  println(problem1(A))
  println(problem2(A))
end
