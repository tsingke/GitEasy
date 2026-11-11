#include "campus/ledger_export.hpp"
#include "campus/money.hpp"
#include <sstream>
namespace campus {
namespace {
// CSV字段中的双引号需要成对转义；字段整体保留引号。
std::string csv(const std::string &value) {
    std::string result = "\"";
    for (char ch : value) {
        if (ch == '\"')
            result += '\"';
        result += ch;
    }
    return result + '\"';
}
} // namespace
std::string exportLedgerCsv(const std::vector<Transaction> &transactions) {
    std::ostringstream out;
    out << "request_id,card_id,operation,amount,balance_after,day,currency\n";
    for (const auto &item : transactions)
        out << csv(item.requestId) << ',' << csv(item.cardId) << ','
            << (item.operation == Operation::TopUp ? "topup" : "payment") << ','
            << formatMoney(item.amount) << ',' << formatMoney(item.balanceAfter) << ',' << item.day
            << ",CNY\n";
    return out.str();
}
} // namespace campus
