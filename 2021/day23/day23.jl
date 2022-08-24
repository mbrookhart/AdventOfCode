using DataStructures

const energy = Dict('A'=>1,
                    'B'=>10,
                    'C'=>100,
                    'D'=>1000)

const goals = Dict('A'=>4,
                   'B'=>6,
                   'C'=>8,
                   'D'=>10)

const hall = [2, 3, 5, 7, 9, 11, 12]

struct Amphipod
  loc::Int64
  room::Int64
  depth::Int64
  type::Char
end

function Base.hash(a::Amphipod, h::UInt)
  hash((a.loc, a.room, a.depth, a.type), h)
end

const test_state = (Amphipod(-1, 4, 1, 'B'), Amphipod(-1, 6, 1, 'C'), Amphipod(-1, 8, 1, 'B'), Amphipod(-1, 10, 1, 'D'), Amphipod(-1, 4, 2, 'A'), Amphipod(-1, 6, 2, 'D'), Amphipod(-1, 8, 2, 'C'), Amphipod(-1, 10, 2, 'A'))

function room_ready(state, room)
  in_room = filter(x->x.room == room, state)
  length(in_room) == 0 || mapreduce(x->goals[x.type] == room, &, in_room)
end

function can_leave_room(state, amphipod)
  amphipod.depth > 0 && (amphipod.room != goals[amphipod.type] || !room_ready(state, amphipod.room)) && (amphipod.depth == 1 || 
                         length(filter(x->x != amphipod && x.room == amphipod.room && x.depth < amphipod.depth, state)) == 0)
end

@assert can_leave_room(test_state, test_state[1])
@assert can_leave_room(test_state, test_state[2])
@assert can_leave_room(test_state, test_state[3])
@assert can_leave_room(test_state, test_state[4])
@assert !can_leave_room(test_state, test_state[5])
@assert !can_leave_room(test_state, test_state[6])
@assert !can_leave_room(test_state, test_state[7])
@assert !can_leave_room(test_state, test_state[8])


function can_move(state, amphipod, x2)
  x1 = amphipod.loc > 0 ? amphipod.loc : amphipod.room
  x1, x2 = sort([x1, x2])
  length(filter(x->x != amphipod && x1<= x.loc && x.loc <= x2, state)) == 0
end

@assert can_move((Amphipod(0, 4, 1, 'B'), Amphipod(0, 6, 1, 'C')), Amphipod(0, 4, 1, 'B'), 11)
@assert !can_move((Amphipod(0, 4, 1, 'B'), Amphipod(7, 0, 0, 'C')), Amphipod(0, 4, 1, 'B'), 11)

function new_state(state, amphipod, new_amphipod)
  map(x->x == amphipod ? new_amphipod : x, state)
end

@assert new_state((Amphipod(0, 4, 1, 'B'), Amphipod(0, 6, 1, 'C')), Amphipod(0, 4, 1, 'B'), Amphipod(3, 0, 0, 'B')) == (Amphipod(3, 0, 0, 'B'), Amphipod(0, 6, 1, 'C'))

function room_depth(state, room, max_depth)
  in_room = filter(x->x.room == room, state)
  length(in_room) > 0 ? minimum(map(x->x.depth, in_room)) : max_depth + 1
end

@assert room_depth((Amphipod(0, 6, 2, 'C'), Amphipod(0, 6, 1, 'C')), 6, 2) == 1
@assert room_depth((Amphipod(3, 0, 0, 'C'), Amphipod(0, 6, 1, 'C')), 6, 2) == 1
@assert room_depth((Amphipod(0, 6, 2, 'C'), Amphipod(0, 6, 1, 'C')), 8, 2) == 3

function in_hall(amphipod)
  amphipod.loc > 0
end

function move_cost(amphipod, new_amphipod)
  energy[amphipod.type] * (abs(amphipod.depth) + 
                           abs(new_amphipod.depth) + 
                           abs(amphipod.loc + 
                               amphipod.room - 
                               (new_amphipod.loc + 
                                new_amphipod.room)))
end


function double_room(state)
  any([i!=j && state[i].loc == state[j].loc && state[i].room == state[j].room && state[i].depth == state[j].depth for i in 1:length(state), j in 1:length(state)])
end

function generate_moves(state::T, amphipod, cost, max_depth) where T
  moves = Array{T, 1}(undef, 0)
  costs = Array{Int64, 1}(undef, 0)
  if in_hall(amphipod)
    # Try to move into final room
    target_room = goals[amphipod.type]
    if room_ready(state, target_room) && can_move(state, amphipod, target_room)
      new_amphipod = Amphipod(0, target_room, room_depth(state, target_room, max_depth) - 1, amphipod.type)
      push!(costs, cost + move_cost(amphipod, new_amphipod))
      push!(moves, new_state(state, amphipod,new_amphipod))
    end
  else
    if can_leave_room(state, amphipod)
      target_room = goals[amphipod.type]
      if room_ready(state, target_room) && can_move(state, amphipod, target_room)
        #Try to move directly to the final room
        new_amphipod = Amphipod(0, target_room, room_depth(state, target_room, max_depth) - 1, amphipod.type)
        push!(costs, cost + move_cost(amphipod, new_amphipod))
        push!(moves, new_state(state, amphipod, new_amphipod))
      else
        #Else move to the hall
        for loc in hall
          if can_move(state, amphipod, loc)
            new_amphipod = Amphipod(loc, 0, 0, amphipod.type)
            push!(costs, cost + move_cost(amphipod, new_amphipod))
            push!(moves, new_state(state, amphipod, new_amphipod))
          end
        end
      end
    end
  end
  moves, costs
end

function add!(queue, next, priority)
    if haskey(queue, next) && (queue[next] > priority)
        queue[next] = priority
    else 
      enqueue!(queue, next, priority)
    end
end

function matches_goal(state)
  mapreduce(x->goals[x.type] == x.room, &,  state)
end

@assert matches_goal(Tuple([Amphipod(0, goals[x], i, x) for i in 1:2, x in keys(goals)]))

function heuristic(goal, next)
  0
end

function Astar(start::T, max_depth) where T
  goal = Tuple([Amphipod(-1, -1, -1, '?') for _ in 1:length(start)])
  queue = PriorityQueue{T, Int64}()
  enqueue!(queue, start, 0)
  came_from = Dict{T, T}()
  cost_so_far = Dict{T, Int64}() 
  came_from[start] = goal
  cost_so_far[start] = 0
  i = 0
  while length(queue) > 0
    current = dequeue!(queue)
    if matches_goal(current)
      return cost_so_far[current]
    end
    for amphipod in current
      neighbors, costs = generate_moves(current, amphipod, cost_so_far[current], max_depth)
      for (next, new_cost) in zip(neighbors, costs)
        if !(haskey(cost_so_far, next)) || (new_cost < cost_so_far[next])
          cost_so_far[next] = new_cost
          priority = new_cost + heuristic(goal, next)
          add!(queue, next, priority)
          came_from[next] = current
        end
      end
    end
  end
  println("failed to find a solution")
  -1
end

function problem1(state)
  Astar(state, 2)
end

function problem2(state)
  Astar(state, 4)
end

function load(file)
  out = Array{Amphipod, 1}(undef, 0)
  lines = readlines(file)
  for j in 1:length(lines)
    line = lines[j]
    for i in 1:length(line)
      if isletter(line[i])
        push!(out, Amphipod(0, i, j - 2, line[i]))
      end
    end
  end
  Tuple(out)
end

using Profile
if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test.txt")
  @time @assert problem1(A) == 12521
  A = load("test2.txt")
  @time @assert problem2(A) == 44169
  
  A = load("input.txt")
  @time println(problem1(A))
  A = load("input2.txt")
  @time println(problem2(A))
end
