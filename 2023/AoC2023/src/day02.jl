module day02

using InlineTest
using Match
const TEST_STRING = """
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
"""

Draw = Vector{Int}

struct Game
    id::Int
    draws::Array{Draw}
end

function parse_draw(line)
    d = zeros(3)
    items = strip.(split(line, ","))
    colors = Dict("red" => 1, "green" => 2, "blue" => 3)
    for item in items
        n, c = strip.(split(item, " "))
        d[colors[c]] += parse(Int, n)
    end
    d
end

function parse_game(line)
    g, ds = strip.(split(line, ":"))
    Game(parse(Int, split(g, " ")[end]), parse_draw.(split(ds, ";")))
end

function load(file)
    parse_game.(readlines(file))
end

function problem1(io::IO)
    games = load(io)
    bag = [12, 13, 14]
    total = 0
    for g in games
        if all([all(draw .<= bag) for draw in g.draws])
            total += g.id
        end
    end
    total
end

function problem2(io::IO)
    games = load(io)
    total = 0
    for g in games
        total +=
            maximum([draw[1] for draw in g.draws]) *
            maximum([draw[2] for draw in g.draws]) *
            maximum([draw[3] for draw in g.draws])
    end
    total
end

@assert problem1(IOBuffer(TEST_STRING)) == 8
@assert problem2(IOBuffer(TEST_STRING)) == 2286

end
