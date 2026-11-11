#ifndef CAMPUS_MONEY_HPP
#define CAMPUS_MONEY_HPP
#include "campus/types.hpp"
namespace campus {
// 教学原型允许的余额上限：1 000 000.00元。命名常量避免多处复制规则。
constexpr Cents MaxBalance = 100000000;
// 直接按十进制数字解析，拒绝负号、空文本和超过两位的小数。
Cents parseMoney(const std::string &text);
// 把非负整数分转换为固定两位小数的展示文本。
std::string formatMoney(Cents amount);
} // namespace campus
#endif
