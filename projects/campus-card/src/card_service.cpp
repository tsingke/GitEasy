#include "campus/card_service.hpp"
#include "campus/ledger_export.hpp"
#include <algorithm>
#include <utility>
namespace campus {
CardService::CardService(DayProvider provider) : dayProvider_(std::move(provider)) {
    if (!dayProvider_)
        throw std::invalid_argument("Business day provider is required");
}
void CardService::open(const std::string &id, std::unique_ptr<CardHolder> holder) {
    // 与持卡人身份采用同一非空白约束，界面和CLI共用此入口。
    if (id.find_first_not_of(" \t\r\n") == std::string::npos)
        throw std::invalid_argument("Card id is required");
    if (cards_.count(id))
        throw std::invalid_argument("Card already exists");
    std::unique_ptr<Card> value(new Card{id, std::move(holder), 0, CardState::Active});
    cards_.emplace(id, std::move(value));
}
void CardService::openStudent(const std::string &id, const std::string &holder,
                              const std::string &name) {
    open(id, std::unique_ptr<CardHolder>(new StudentHolder(holder, name)));
}
void CardService::openStaff(const std::string &id, const std::string &holder,
                            const std::string &name) {
    open(id, std::unique_ptr<CardHolder>(new StaffHolder(holder, name)));
}
CardService::Card &CardService::requireCard(const std::string &id) {
    auto it = cards_.find(id);
    if (it == cards_.end())
        throw std::out_of_range("Unknown card");
    return *it->second;
}
const CardService::Card &CardService::requireCard(const std::string &id) const {
    auto it = cards_.find(id);
    if (it == cards_.end())
        throw std::out_of_range("Unknown card");
    return *it->second;
}
Transaction CardService::transact(const std::string &id, Cents amount, const std::string &request,
                                  Operation operation, const std::string &day) {
    if (amount <= 0 || amount > MaxBalance)
        throw std::invalid_argument("Amount must be positive and within the demo limit");
    if (request.empty())
        throw std::invalid_argument("Request id is required");
    if (!isValidBusinessDay(day))
        throw std::invalid_argument("Day must be a real YYYY-MM-DD date");
    // 幂等检查先于再次记账：相同请求返回原回执，参数冲突拒绝。
    auto old = receipts_.find(request);
    if (old != receipts_.end()) {
        const Transaction &receipt = old->second;
        if (receipt.cardId != id || receipt.operation != operation || receipt.amount != amount ||
            receipt.day != day)
            throw std::invalid_argument("Request id conflicts with a different operation");
        return receipt;
    }
    Card &target = requireCard(id);
    if (target.state != CardState::Active)
        throw std::logic_error("Card is reported lost");
    Cents next = target.balance;
    if (operation == Operation::TopUp) {
        if (amount > MaxBalance - next)
            throw std::out_of_range("Balance exceeds demo limit");
        next += amount;
    } else {
        // BOOK_PAYMENT_CHECK_BEGIN
        if (amount > next)
            throw std::logic_error("Insufficient balance");
        Cents spent = 0;
        for (const auto &item : transactions_)
            if (item.cardId == id && item.operation == Operation::Payment && item.day == day)
                spent += item.amount;
        if (amount > target.holder->dailyLimit() - spent)
            throw std::logic_error("Daily payment limit exceeded");
        next -= amount;
        // BOOK_PAYMENT_CHECK_END
    }
    // 校验和计算结束后准备记录；索引分配失败时撤回新流水。
    Transaction receipt{request, id, operation, amount, next, day};
    transactions_.push_back(receipt);
    try {
        receipts_.emplace(request, receipt);
    } catch (...) {
        transactions_.pop_back();
        throw;
    }
    target.balance = next;
    return receipt;
}
Transaction CardService::topUp(const std::string &id, Cents amount, const std::string &request) {
    return transact(id, amount, request, Operation::TopUp, dayProvider_());
}
// 无显式日期的入口使用注入依赖；四参数入口便于回放指定业务日。
Transaction CardService::pay(const std::string &id, Cents amount, const std::string &request) {
    return pay(id, amount, request, dayProvider_());
}
Transaction CardService::pay(const std::string &id, Cents amount, const std::string &request,
                             const std::string &day) {
    return transact(id, amount, request, Operation::Payment, day);
}
void CardService::reportLost(const std::string &id) {
    requireCard(id).state = CardState::Lost;
}
void CardService::reactivate(const std::string &id) {
    requireCard(id).state = CardState::Active;
}
CardView CardService::card(const std::string &id) const {
    const Card &item = requireCard(id);
    return CardView{item.id, item.holder->name(), item.holder->category(), item.balance,
                    item.state};
}
std::vector<CardView> CardService::cards() const {
    std::vector<CardView> result;
    for (const auto &item : cards_)
        result.push_back(card(item.first));
    std::sort(result.begin(), result.end(),
              [](const CardView &a, const CardView &b) { return a.cardId < b.cardId; });
    return result;
}
// 报告格式由独立模块负责，服务只提供已记录的流水。
std::string CardService::exportCsv() const {
    return exportLedgerCsv(transactions_);
}
} // namespace campus
