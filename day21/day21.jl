mutable struct Player
  position::Int64
  score::Int64
end

mutable struct DetDie
  value::Int64
  roll_count::Int64
end

function Player(position)
  Player(position, 0)
end

function DetDie()
  DetDie(0, 0)
end

function roll(die::DetDie)
  val = die.value
  val += 1
  die.value = val % 100
  die.roll_count += 1
  val
end

function roll!(player::Player, die)
  val = sum([roll(die), roll(die), roll(die)])
  player.position += val
  while player.position > 10
    player.position -= 10
  end
  player.score += player.position
end

function game(start1, start2, die)
  die = deepcopy(die)
  p1 = Player(start1)
  p2 = Player(start2)
  i = 0
  while p1.score < 1000 && p2.score < 1000
    if i % 2 == 0
      roll!(p1, die)
    else
      roll!(p2, die)
    end
    i += 1
  end
  return min(p1.score, p2.score) * die.roll_count
end

function problem1(start1, start2)
  game(start1, start2, DetDie())
end

function update_player(p::Player, roll::Int64)
  new_pos = p.position + roll
  while new_pos > 10
    new_pos -= 10
  end
  new_score = p.score + new_pos
  Player(new_pos, new_score)
end

function memoize(p1::Player, p2::Player, turn, wins, memo)
  memo[[p1.position, p1.score, p2.position, p2.score, turn]] = wins
  wins
end

const rolls = reduce(vcat, [i + j + k for i in 1:3, j in 1:3, k in 1:3])

function play(p1::Player, p2::Player, score, turn, memo)
  if [p1.position, p1.score, p2.position, p2.score, turn] in keys(memo)
    return memo[[p1.position, p1.score, p2.position, p2.score, turn]]
  end
  if p1.score >= score
    return memoize(p1, p2, turn, [1, 0], memo)
  elseif p2.score >= score
    return memoize(p1, p2, turn, [0, 1], memo)
  end
  wins = [0, 0]
  if turn == 0
    for roll in rolls
      wins .+= play(update_player(p1, roll), p2, score, 1, memo)
    end
  else
    for roll in rolls
      wins .+= play(p1, update_player(p2, roll), score, 0, memo)
    end
  end
  memoize(p1, p2, turn, wins, memo)
end

function problem2(start1, start2)
  p1 = Player(start1)
  p2 = Player(start2)
  memo = Dict{Array{Int64, 1}, Array{Int64, 1}}()
  maximum(play(p1, p2, 21, 0, memo))
end

if abspath(PROGRAM_FILE) == @__FILE__
  @assert problem1(4, 8) == 739785
  @assert problem2(4, 8) == 444356092776315

  println(problem1(6, 4))
  println(problem2(6, 4))
end
