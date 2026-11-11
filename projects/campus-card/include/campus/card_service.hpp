#ifndef CAMPUS_CARD_SERVICE_HPP
#define CAMPUS_CARD_SERVICE_HPP
#include "campus/business_date.hpp"
#include "campus/card_holder.hpp"
#include "campus/money.hpp"
#include "campus/types.hpp"
#include <memory>
#include <stdexcept>
#include <unordered_map>
#include <vector>
namespace campus {
// 应用入口统一实施账户规则；本类不依赖Qt，也不操作文件对话框。
class CardService {
  public:
    // 默认读取系统日期；测试和业务回放可传入lambda或其他可调用对象。
    explicit CardService(DayProvider provider = today);
    CardService(const CardService &) = delete;
    CardService &operator=(const CardService &) = delete;
    CardService(CardService &&) = default;
    CardService &operator=(CardService &&) = default;
    void openStudent(const std::string &cardId, const std::string &holderId,
                     const std::string &name);
    void openStaff(const std::string &cardId, const std::string &holderId, const std::string &name);
    Transaction topUp(const std::string &cardId, Cents amount, const std::string &requestId);
    Transaction pay(const std::string &cardId, Cents amount, const std::string &requestId);
    Transaction pay(const std::string &cardId, Cents amount, const std::string &requestId,
                    const std::string &day);
    void reportLost(const std::string &cardId);
    void reactivate(const std::string &cardId);
    CardView card(const std::string &cardId) const;
    std::vector<CardView> cards() const;
    // 借用只读流水；后续交易可能使先前取得的迭代器失效。
    const std::vector<Transaction> &history() const {
        return transactions_;
    }
    std::string exportCsv() const;

  private:
    struct Card {
        std::string id;
        std::unique_ptr<CardHolder> holder;
        Cents balance;
        CardState state;
    };
    void open(const std::string &cardId, std::unique_ptr<CardHolder> holder);
    Card &requireCard(const std::string &id);
    const Card &requireCard(const std::string &id) const;
    Transaction transact(const std::string &cardId, Cents amount, const std::string &requestId,
                         Operation operation, const std::string &day);
    DayProvider dayProvider_;
    // 独占所有权管理账户与多态持卡人，外部调用者不能直接改余额。
    std::unordered_map<std::string, std::unique_ptr<Card>> cards_;
    std::vector<Transaction> transactions_;
    std::unordered_map<std::string, Transaction> receipts_;
};
} // namespace campus
#endif
