#include <fstream>
#include <functional>
#include <string>

void load(const std::string& filename, const std::function<void(std::string)>& func) {
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
