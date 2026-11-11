#include "campus/business_date.hpp"
#include <chrono>
#include <ctime>
#include <stdexcept>
namespace campus {
// 日期先检查格式，再按闰年规则检查真实日历范围。
bool isValidBusinessDay(const std::string &text) {
    if (text.size() != 10 || text[4] != '-' || text[7] != '-')
        return false;
    for (std::size_t i = 0; i < text.size(); ++i)
        if (i != 4 && i != 7 && (text[i] < '0' || text[i] > '9'))
            return false;
    int year = std::stoi(text.substr(0, 4)), month = std::stoi(text.substr(5, 2)),
        day = std::stoi(text.substr(8, 2));
    if (year < 1 || month < 1 || month > 12)
        return false;
    const int days[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    int maximum = days[month - 1];
    if (month == 2 && year % 4 == 0 && (year % 100 != 0 || year % 400 == 0))
        ++maximum;
    return day >= 1 && day <= maximum;
}
std::string today() {
    std::time_t now = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    const std::tm *local = std::localtime(&now);
    if (!local)
        throw std::runtime_error("Clock conversion failed");
    std::tm date = *local;
    char buffer[11];
    if (!std::strftime(buffer, sizeof(buffer), "%Y-%m-%d", &date))
        throw std::runtime_error("Clock formatting failed");
    return buffer;
}
} // namespace campus
