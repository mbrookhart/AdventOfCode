module day04

using InlineTest
using Match
const TEST_STRING = raw"""
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
"""

struct Card
    id::Int
    drawn::Vector{Int}
    played::Vector{Int}
end

function create_card(line)
    id, card = split(line, ":")
    draw, played = strip.(split(card, "|"))
    id = parse(Int, split(id, " ")[end])
    draw = parse.(Int, split(draw))
    played = parse.(Int, split(played))
    Card(id, draw, played)
end

num_winning(card) = length(card.played[in.(card.played, Ref(card.drawn))])

function score(card)
    N = num_winning(card)
    if N > 0
        return 2^(N - 1)
    end
    0
end

function load(file)
    create_card.(readlines(file))
end

function problem1(io::IO)
    sum(score.(load(io)))
end

function problem2(io::IO)
    cards = load(io)
    N = length(cards)
    Ns = num_winning.(cards)
    card_dups = ones(Int, N)
    for i = 1:length(cards)
        j = Ns[i]
        card_dups[i+1:i+j] .+= card_dups[i]
    end
    sum(card_dups)
end

@assert problem1(IOBuffer(TEST_STRING)) == 13
@assert problem2(IOBuffer(TEST_STRING)) == 30

end
