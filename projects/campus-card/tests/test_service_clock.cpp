#include "campus/card_service.hpp"
#include "test_support.hpp"
int main() {
    try {
        Checks check;
        std::string day = "2026-11-12";
        campus::CardService service([&day] { return day; });
        check.rejects([&] { service.openStudent("   ", "blank-id", "Demo"); },
                      "blank card id accepted");
        service.openStudent("S1", "student-1", "Demo");
        const auto first = service.topUp("S1", 10000, "R1");
        check.require(first.day == day, "topup must use injected date");
        service.topUp("S1", 10000, "R1");
        check.require(service.history().size() == 1 && service.card("S1").balance == 10000,
                      "topup retry duplicated");
        const auto payment = service.pay("S1", 100, "R2");
        check.require(payment.day == day && payment.balanceAfter == 9900,
                      "payment must use injected date");
        day = "2026-11-13";
        check.rejects([&] { service.topUp("S1", 10000, "R1"); }, "request changed business day");
        check.require(service.card("S1").balance == 9900 && service.history().size() == 2,
                      "rejection mutated state");
        day = "invalid";
        check.rejects([&] { service.pay("S1", 100, "R3"); }, "invalid provider day accepted");
        check.rejects([] { campus::CardService empty{campus::DayProvider()}; },
                      "empty provider accepted");
        return check.finish("clock");
    } catch (const std::exception &error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
