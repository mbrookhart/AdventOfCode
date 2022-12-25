module day25

using InlineTest
using Match
using DataStructures

@testset "day25" begin
  @test decimal_to_snafu(1747) == "1=-0-2"
  @test decimal_to_snafu(906) == "12111"
  @test decimal_to_snafu(198) == "2=0="
  @test decimal_to_snafu(11) == "21"
  @test decimal_to_snafu(32) == "112"
  @test solve(open("../data/day25.test")) == (
    "2=-1=0",
  )
end

function load(file)
  readlines(file)
end

function snafu_to_decimal(N)
  N = reverse(collect(N))
  val = 0
  for i in 1:length(N)
    val += 5^(i-1) * @match N[i] begin
      '2' => 2
      '1' => 1
      '0' => 0
      '-' => -1
      '=' => -2
    end

  end
  val
end

fits_in_num_snafu_digits(d, N) = d < sum([2*5^(i-1) for i in 1:N])

function find_num_digits(d)
  i = 1
  while true
    if fits_in_num_snafu_digits(d, i)
      return i
    end
    i += 1
  end
end

function find_first_digit(d, N)
  res = d - 5^(N-1)
  if fits_in_num_snafu_digits(res, N - 1)
    return res, "1"
  else
    return d - 2* 5^(N-1), "2"
  end
end

function decimal_to_snafu(d)
  N = find_num_digits(d)
  num = ""
  res = d
  for i in N:-1:1
    pow = 5^(i-1)
    digit = round(Int, (res + 2 * pow) / pow) - 2
    num *= @match digit begin
      -2 => "="
      -1 => "-"
       0 => "0"
       1 => "1"
       2 => "2"
    end
    res -= digit * pow
  end
  num
end

function problem1(data)
  decimal_to_snafu(sum(snafu_to_decimal.(data)))
end

function problem2(data)
end

function solve(io::IO)
  data = load(io)
  (
    problem1(deepcopy(data)),
    #problem2(deepcopy(data))
  )
end

end