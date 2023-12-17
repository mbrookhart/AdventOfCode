module day03

using InlineTest
using Match
const TEST_STRING = raw"""
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
"""


function load(file)
    lines = readlines(file)
    grid = Matrix{Char}(undef, length(lines), length(lines[1]))
    for i = 1:length(lines)
        grid[i, :] = collect(lines[i])
    end
    grid
end

function grow_symbols!(symbols)
    N, M = size(symbols)
    pos = findall(!=(0), symbols)
    check(k, K) = (k > 0) && (k <= K)
    for p in pos
        for i = -1:1, j = -1:1
            x, y = p[1] + i, p[2] + j
            if check(x, N) && check(y, M)
                symbols[x, y] = 1
            end
        end
    end
end

function get_adjacent_nums(engine, digits, symbols)
    N, M = size(symbols)
    nums = Vector{Int}()
    for i = 1:N
        current = Vector{Char}()
        adjacent = false
        in = false
        for j = 1:N
            if digits[i, j]
                push!(current, engine[i, j])
                adjacent |= symbols[i, j]
                in = true
            else
                if in && adjacent
                    push!(nums, parse(Int, String(current)))
                end
                current = Vector{Char}()
                adjacent = false
                in = false
            end
        end
        if in && adjacent
            push!(nums, parse(Int, String(current)))
        end
    end
    nums
end

function problem1(io::IO)
    engine = load(io)
    digits = isdigit.(engine)
    symbols = (engine .!= '.') .& .!digits
    grow_symbols!(symbols)
    sum(get_adjacent_nums(engine, digits, symbols))
end

function problem2(io::IO)
    engine = load(io)
    digits = isdigit.(engine)
    gears = findall(==('*'), engine)
    symbols = zeros(Bool, size(digits))
    total = 0
    for gear in gears
        symbols[gear] = 1
        grow_symbols!(symbols)
        nums = get_adjacent_nums(engine, digits, symbols)
        if length(nums) == 2
            total += reduce(*, nums)
        end
        symbols .= 0
    end
    total
end

@assert problem1(IOBuffer(TEST_STRING)) == 4361
@assert problem2(IOBuffer(TEST_STRING)) == 467835

end
