#include <fstream>
#include <functional>
#include <sstream>
#include <string>
#include <vector>

void load(const std::string &filename,
          const std::function<void(std::string)> &func) {
  std::vector<std::vector<int>> out = {{}};
  std::ifstream file(filename);
  if (file.is_open()) {
    std::string line;
    while (std::getline(file, line)) {
      func(line);
    }
    file.close();
  }
}

std::vector<std::string> split(const std::string &input, char delim) {
  std::stringstream sinput(input);
  std::string segment;
  std::vector<std::string> output;
  while (std::getline(sinput, segment, delim)) {
    output.push_back(segment);
  }
  return output;
}
