#include "campus/card_service.hpp"
#include <iostream>
int main() {
    campus::CardService service;
    service.openStudent("S001","student-demo","Demo Student");
    service.openStaff("T001","staff-demo","Demo Staff");
    service.topUp("S001",campus::parseMoney("100.00"),"demo-topup-1");
    service.pay("S001",campus::parseMoney("23.50"),"demo-pay-1","2026-11-11");
    service.reportLost("S001");
    try {service.pay("S001",100,"demo-rejected","2026-11-11");}
    catch(const std::logic_error& error) {std::cout<<"Expected rejection: "<<error.what()<<'\n';}
    service.reactivate("S001");
    std::cout<<"S001 balance: "<<campus::formatMoney(service.card("S001").balance)<<'\n';
    std::cout<<service.exportCsv();
}
