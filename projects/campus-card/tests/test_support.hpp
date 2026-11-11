#ifndef CAMPUS_TEST_SUPPORT_HPP
#define CAMPUS_TEST_SUPPORT_HPP
#include <functional>
#include <iostream>
#include <stdexcept>
// 使用可执行检查而非assert，确保Release构建也执行全部断言。
class Checks {
  public:
    void require(bool condition, const char *message) {
        ++count_;
        if (!condition)
            throw std::runtime_error(message);
    }
    void rejects(const std::function<void()> &action, const char *message) {
        bool rejected = false;
        try {
            action();
        } catch (const std::exception &) {
            rejected = true;
        }
        require(rejected, message);
    }
    int finish(const char *suite) const {
        std::cout << "PASS " << count_ << ' ' << suite << " assertions\n";
        return 0;
    }

  private:
    int count_ = 0;
};
#endif
