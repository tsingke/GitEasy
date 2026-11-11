#ifndef CAMPUS_TYPES_HPP
#define CAMPUS_TYPES_HPP
#include <cstdint>
#include <string>
namespace campus {
// 金额的唯一内部单位是“分”，禁止把浮点近似值写入余额。
using Cents = std::int64_t;
enum class CardState { Active, Lost };
enum class Operation { TopUp, Payment };
// 查询结果按值返回；修改此视图不会绕过服务修改账户。
struct CardView {
    std::string cardId;
    std::string holderName;
    std::string category;
    Cents balance;
    CardState state;
};
struct Transaction {
    std::string requestId;
    std::string cardId;
    Operation operation;
    Cents amount;
    Cents balanceAfter;
    std::string day;
};
} // namespace campus
#endif
