#include "campus/ledger_export.hpp"
#include "test_support.hpp"
int main() {
    try {
        Checks check;
        std::vector<campus::Transaction> entries{
            {"R,\"1\"", "S,1", campus::Operation::Payment, 5, 995, "2026-11-12"}};
        const auto text = campus::exportLedgerCsv(entries);
        check.require(text.find("request_id,card_id,operation,amount,balance_after,day") == 0,
                      "CSV columns");
        check.require(text.find("\"R,\"\"1\"\"\"") != std::string::npos, "CSV quote escaping");
        check.require(text.find("\"S,1\"") != std::string::npos, "CSV comma escaping");
        check.require(text.find(",payment,0.05,9.95,2026-11-12") != std::string::npos,
                      "CSV values");
        // CAMPUS_LAB_CURRENCY_BEGIN
        check.require(text.find(",CNY\n") != std::string::npos, "CSV currency");
        // CAMPUS_LAB_CURRENCY_END
        check.require(entries.size() == 1 && entries[0].amount == 5,
                      "export must not mutate input");
        return check.finish("export");
    } catch (const std::exception &error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
