#include "campus/money.hpp"
#include "test_support.hpp"
int main() {
    try {
        Checks check;
        const campus::Cents values[] = {0, 1, 99, 100, 12345, campus::MaxBalance};
        for (campus::Cents value : values)
            check.require(campus::parseMoney(campus::formatMoney(value)) == value,
                          "money round trip");
        check.require(campus::parseMoney("00012.30") == 1230, "leading zeroes");
        for (const auto &text : {"1..0", "1.000", "+1", "1e2", " 1", "1000000.01"})
            check.rejects([&] { campus::parseMoney(text); }, "invalid decimal accepted");
        check.rejects([] { campus::formatMoney(-1); }, "negative display accepted");
        return check.finish("money");
    } catch (const std::exception &error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
