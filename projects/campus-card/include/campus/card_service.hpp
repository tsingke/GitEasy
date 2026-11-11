#ifndef CAMPUS_CARD_SERVICE_HPP
#define CAMPUS_CARD_SERVICE_HPP
#include <cstdint>
#include <memory>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <vector>
namespace campus {
typedef std::int64_t Cents;
Cents parseMoney(const std::string& text);
std::string formatMoney(Cents amount);
std::string today();
enum class CardState { Active, Lost };
enum class Operation { TopUp, Payment };
class CardHolder {
public:
    CardHolder(std::string id, std::string name);
    virtual ~CardHolder() = default;
    const std::string& id() const { return id_; }
    const std::string& name() const { return name_; }
    virtual std::string category() const = 0;
    virtual Cents dailyLimit() const = 0;
private:
    std::string id_;
    std::string name_;
};
class StudentHolder : public CardHolder {
public:
    using CardHolder::CardHolder;
    std::string category() const override { return "Student"; }
    Cents dailyLimit() const override { return 50000; }
};
class StaffHolder : public CardHolder {
public:
    using CardHolder::CardHolder;
    std::string category() const override { return "Staff"; }
    Cents dailyLimit() const override { return 100000; }
};
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
class CardService {
public:
    void openStudent(const std::string& cardId, const std::string& holderId, const std::string& name);
    void openStaff(const std::string& cardId, const std::string& holderId, const std::string& name);
    Transaction topUp(const std::string& cardId, Cents amount, const std::string& requestId);
    Transaction pay(const std::string& cardId, Cents amount, const std::string& requestId, const std::string& day = today());
    void reportLost(const std::string& cardId);
    void reactivate(const std::string& cardId);
    CardView card(const std::string& cardId) const;
    std::vector<CardView> cards() const;
    const std::vector<Transaction>& history() const { return transactions_; }
    std::string exportCsv() const;
private:
    struct Card {
        std::string id;
        std::unique_ptr<CardHolder> holder;
        Cents balance;
        CardState state;
    };
    void open(const std::string& cardId, std::unique_ptr<CardHolder> holder);
    Card& requireCard(const std::string& id);
    const Card& requireCard(const std::string& id) const;
    Transaction transact(const std::string& cardId, Cents amount, const std::string& requestId,
                         Operation operation, const std::string& day);
    std::unordered_map<std::string, std::unique_ptr<Card> > cards_;
    std::vector<Transaction> transactions_;
    std::unordered_map<std::string, Transaction> receipts_;
};
}
#endif
