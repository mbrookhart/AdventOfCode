#include <algorithm>
#include <iostream>
#include <numeric>
#include <vector>

#include "utils.h"

enum RPS { Rock = 1, Paper = 2, Sissors = 3 };

struct MovePair {
  RPS elf;
  RPS me;
};

RPS get_move_that_beats(RPS rps) {
  switch (rps) {
  case Rock:
    return Paper;
  case Paper:
    return Sissors;
  case Sissors:
    return Rock;
  }
  throw;
  return Rock;
}

int win_score(const MovePair &move) {
  int score = 0;
  if (move.elf == move.me) {
    score = 1;
  } else if (get_move_that_beats(move.elf) == move.me) {
    score = 2;
  }
  return score * 3;
}

int score(const MovePair &move) { return win_score(move) + move.me; }

int problem1(std::vector<MovePair> moves) {
  std::vector<int> scores;
  for (auto move : moves) {
    scores.push_back(score(move));
  }
  return std::reduce(scores.begin(), scores.end());
}

RPS get_move_that_loses(RPS rps) {
  switch (rps) {
  case Rock:
    return Sissors;
  case Paper:
    return Rock;
  case Sissors:
    return Paper;
  }
  throw;
  return Rock;
}

MovePair get_new_move(const MovePair &move) {
  switch (move.me) {
  case Rock:
    return MovePair{move.elf, get_move_that_loses(move.elf)};
  case Paper:
    return MovePair{move.elf, move.elf};
  case Sissors:
    return MovePair{move.elf, get_move_that_beats(move.elf)};
  }
  throw;
  return MovePair{Rock, Rock};
}

int problem2(std::vector<MovePair> moves) {
  std::vector<int> scores;
  for (auto move : moves) {
    scores.push_back(score(get_new_move(move)));
  }
  return std::reduce(scores.begin(), scores.end());
}

RPS stoRPS(const std::string &in) {
  if (in == "X" || in == "A") {
    return Rock;
  } else if (in == "Y" || in == "B") {
    return Paper;
  } else if (in == "Z" || in == "C") {
    return Sissors;
  }
  throw;
}

std::vector<MovePair> parse(const std::string &filename) {
  std::vector<MovePair> out;
  load(filename, [&out](const std::string &line) {
    auto move = split(line, ' ');
    out.push_back(MovePair{stoRPS(move[0]), stoRPS(move[1])});
  });
  return out;
}

int main(int argc, char *argv[]) {
  std::string filename(argv[1]);
  auto moves = parse(filename);
  std::cout << problem1(moves) << std::endl;
  std::cout << problem2(moves) << std::endl;
  return 0;
}