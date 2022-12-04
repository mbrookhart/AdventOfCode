#include <algorithm>
#include <iostream>
#include <numeric>
#include <vector>

#include "utils.h"

using Elf = std::vector<int>;
using Elves = std::vector<Elf>;

Elves parse(const std::string &filename) {
  Elves out = {{}};
  load(filename, [&out](const std::string &line) {
    if (line == "") {
      out.push_back({});
    } else {
      out.back().push_back(std::stoi(line));
    }
  });
  return out;
}

Elf sum_backpacks(const Elves &elves) {
  Elf out;
  for (auto elf : elves) {
    out.push_back(std::reduce(elf.begin(), elf.end()));
  }
std:
  sort(out.begin(), out.end(), std::greater<int>());
  return out;
}

int problem1(Elves elves) { return sum_backpacks(elves)[0]; }

int problem2(Elves elves) {
  auto totals = sum_backpacks(elves);
  return std::reduce(totals.begin(), totals.begin() + 3);
}

int main(int argc, char *argv[]) {
  std::string filename(argv[1]);
  auto elves = parse(filename);
  std::cout << problem1(elves) << std::endl;
  std::cout << problem2(elves) << std::endl;
  return 0;
}