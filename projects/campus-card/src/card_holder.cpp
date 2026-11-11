#include "campus/card_holder.hpp"
#include <stdexcept>
#include <utility>
namespace campus {
// 构造时建立身份不变量，派生对象交给服务前已经有效。
CardHolder::CardHolder(std::string id, std::string name)
    : id_(std::move(id)), name_(std::move(name)) {
    // CAMPUS_LAB_IDENTITY_BEGIN
    if (id_.find_first_not_of(" \t\r\n") == std::string::npos ||
        name_.find_first_not_of(" \t\r\n") == std::string::npos)
        throw std::invalid_argument("Holder id and name are required");
    // CAMPUS_LAB_IDENTITY_END
}
} // namespace campus
