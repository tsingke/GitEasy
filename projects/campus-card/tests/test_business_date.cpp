#include "campus/business_date.hpp"
#include "test_support.hpp"
int main() {
    try {
        Checks check;
        for (const auto &day : {"2000-02-29", "2024-02-29", "2026-11-12", "2026-12-31"})
            check.require(campus::isValidBusinessDay(day), "valid day rejected");
        for (const auto &day :
             {"1900-02-29", "2026-02-29", "2026-04-31", "0000-01-01", "2026-1-01", "2026-01-00"})
            check.require(!campus::isValidBusinessDay(day), "invalid day accepted");
        return check.finish("calendar");
    } catch (const std::exception &error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
