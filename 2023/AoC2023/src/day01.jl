module day01

using InlineTest
using Match
const TEST_STRING = """
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
"""

const TEST_STRING_2 = """
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
"""

function check(s, numbers)
    for p in numbers
        if startswith(s, p.first)
            return p.second
        end
    end
    0
end

function parse_digits(line, numbers = [])
    append!(
        numbers,
        [
            "1" => 1,
            "2" => 2,
            "3" => 3,
            "4" => 4,
            "5" => 5,
            "6" => 6,
            "7" => 7,
            "8" => 8,
            "9" => 9,
        ],
    )
    val = 0
    for i = 1:length(line)
        c = check(line[i:end], numbers)
        if c > 0
            val = 10 * c
            break
        end
    end
    for i = length(line):-1:1
        c = check(line[i:end], numbers)
        if c > 0
            val += c
            break
        end
    end
    val
end

function parse_numbers(line)
    numbers = [
        "one" => 1,
        "two" => 2,
        "three" => 3,
        "four" => 4,
        "five" => 5,
        "six" => 6,
        "seven" => 7,
        "eight" => 8,
        "nine" => 9,
    ]

    parse_digits(line, numbers)
end

function load(file)
    readlines(file)
end

function problem1(A)
    sum(parse_digits.(A))
end

function problem2(A)
    sum(parse_numbers.(A))
end

function solve(io::IO)
    A = load(io)
    problem1(A), problem2(A)
end

@assert problem1(load(IOBuffer(TEST_STRING))) == 142
@assert problem2(load(IOBuffer(TEST_STRING_2))) == 281

end
