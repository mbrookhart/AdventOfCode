mutable struct BingoBoard
  vals::Array{Int64, 2}
  mask::Array{Int64, 2}
end

function BingoBoard(vals)
  BingoBoard(vals, zeros(size(vals)))
end

function read_boards(file)
  lines = readlines(file)
  moves = parse.(Int64, split(lines[1], ","))
  @assert all(unique(moves) .== moves)
  boards = Array{BingoBoard}(undef, 0)
  i = 2
  while i < length(lines)
    vals = Array{Int64, 2}(undef, 5, 5)
    for j in 1:5
      vals[j,:] = parse.(Int64, split(lines[i + j]))
    end
    push!(boards, BingoBoard(vals))
    i += 6
  end
  moves, boards
end

function call_number!(board::BingoBoard, value)
  board.mask += (board.vals .== value)
end

function has_bingo(board::BingoBoard)
  any(sum(board.mask, dims=1) .== 5) || any(sum(board.mask, dims=2) .== 5) 
end

function call_number!(boards::Array{BingoBoard, 1}, value)
  for board in boards
    call_number!(board, value)
  end
end

function score_board(board::BingoBoard, move)
  move * sum(board.vals .* Int64.(board.mask .== 0))
end

function problem1(moves, boards)
  boards = deepcopy(boards)
  for i in 1:length(moves)
    call_number!(boards, moves[i])
    for board in boards
      if has_bingo(board)
        #score the first board to get a bingo
        return score_board(board, moves[i])
      end
    end
  end
  0
end

function problem2(moves, boards)
  boards = deepcopy(boards)
  finished_boards = zeros(length(boards))
  for i in 1:length(moves)
    call_number!(boards, moves[i])
    for j in 1:length(boards)
      if finished_boards[j] == 0 && has_bingo(boards[j])
        finished_boards[j] = 1
        if (sum(finished_boards)) == length(boards)
          # score the last board to finish
          return score_board(boards[j], moves[i])
        end
      end
    end
  end
end

if abspath(PROGRAM_FILE) == @__FILE__
  moves, boards = read_boards("test.txt")
  @assert problem1(moves, boards) == 4512
  @assert problem2(moves, boards) == 1924


  moves, boards = read_boards("input.txt")
  println(problem1(moves, boards))
  println(problem2(moves, boards))
end
