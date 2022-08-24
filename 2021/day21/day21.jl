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


const rolls = Dict(3=>1, 4=>3, 5=>6, 6=>7, 7=>6, 8=>3, 9=>1)
const score = 21

struct Board
  pos1::Int64
  score1::Int64
  pos2::Int64
  score2::Int64
  turn::Int64
end

function update_board(board, roll)
  if board.turn == 0
    new_pos = (board.pos1 + roll - 1) % 10 + 1
    new_score = board.score1 + new_pos
    return Board(new_pos, new_score, board.pos2, board.score2, 1)
  else
    new_pos = (board.pos2 + roll - 1) % 10 + 1
    new_score = board.score2 + new_pos
    return Board(board.pos1, board.score1, new_pos, new_score, 0)
  end
end

function memoize(board, wins, memo)
  memo[board] = wins
  wins
end

const K = 0x517cc1b727220a95;

function fxhash(a, h::UInt)
  xor(bitrotate(h, -5), a) * K
end

function Base.hash(a::Board, h::UInt)
  fxhash(a.pos1,
         fxhash(a.score1,
                fxhash(a.pos2,
                       fxhash(a.score2,
                              fxhash(a.turn, h)
                             )
                      )
               )
        )
end

function play(board, memo)
  board2 = Board(board.pos2, board.score2, board.pos1, board.score1, (board.turn + 1) % 2)
  if haskey(memo, board)
    return memo[board]
  elseif haskey(memo, board2)
    tmp = memo[board2]
    return (tmp[2], tmp[1])
  end
  if board.score1 >= score
    return memoize(board, (1, 0), memo)
  elseif board.score2 >= score
    return memoize(board, (0, 1), memo)
  end
  wins = (0, 0)
  for roll in keys(rolls)
    tmp = play(update_board(board, roll), memo)
    wins = (wins[1] + rolls[roll] * tmp[1], wins[2] + rolls[roll] * tmp[2])
  end
  memoize(board, wins, memo)
end

function problem2(start1, start2)
  memo = Dict{Board, NTuple{2, Int64}}()
  maximum(play(Board(start1, 0, start2, 0, 0), memo))
end


if abspath(PROGRAM_FILE) == @__FILE__
  @assert problem1(4, 8) == 739785
  @assert problem2(4, 8) == 444356092776315

  println(problem1(6, 4))
  println(problem2(6, 4))
end
