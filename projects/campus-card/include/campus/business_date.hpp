#ifndef CAMPUS_BUSINESS_DATE_HPP
#define CAMPUS_BUSINESS_DATE_HPP
#include <functional>
#include <string>
namespace campus {
// 可注入的业务日期，使测试不依赖执行当天或计算机时区。
using DayProvider = std::function<std::string()>;
bool isValidBusinessDay(const std::string &text);
// 默认适配器读取本机日历；本工程按单线程服务台程序使用。
std::string today();
} // namespace campus
#endif
