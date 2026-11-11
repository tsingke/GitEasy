#include "campus/money.hpp"
#include <iomanip>
#include <sstream>
#include <stdexcept>
namespace campus {
// 全程使用整数运算；累积前检查上限，避免先溢出再判断。
Cents parseMoney(const std::string &text) {
    if (text.empty())
        throw std::invalid_argument("Amount is empty");
    Cents whole = 0, fraction = 0;
    bool dot = false;
    int digits = 0, integerDigits = 0;
    for (char ch : text) {
        if (ch == '.' && !dot) {
            dot = true;
            continue;
        }
        if (ch < '0' || ch > '9')
            throw std::invalid_argument("Use nonnegative decimal money");
        if (!dot) {
            ++integerDigits;
            if (whole > (MaxBalance / 100 - (ch - '0')) / 10)
                throw std::out_of_range("Amount exceeds demo limit");
            whole = whole * 10 + (ch - '0');
        } else {
            if (++digits > 2)
                throw std::invalid_argument("At most two decimal places");
            fraction = fraction * 10 + (ch - '0');
        }
    }
    if (integerDigits == 0 || (dot && digits == 0))
        throw std::invalid_argument("Incomplete amount");
    if (digits == 1)
        fraction *= 10;
    const Cents result = whole * 100 + fraction;
    if (result > MaxBalance)
        throw std::out_of_range("Amount exceeds demo limit");
    return result;
}
std::string formatMoney(Cents amount) {
    if (amount < 0)
        throw std::invalid_argument("Negative balance");
    std::ostringstream out;
    out << amount / 100 << '.' << std::setw(2) << std::setfill('0') << amount % 100;
    return out.str();
}
} // namespace campus
