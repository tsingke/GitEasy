#include "campus/card_service.hpp"
#include <functional>
#include <iostream>
#include <stdexcept>
using namespace campus;
namespace {
int cases=0;
void check(bool value,const char* message) {++cases;if(!value)throw std::runtime_error(message);}
void rejects(const std::function<void()>& action,const char* message) {
    ++cases;bool rejected=false;try{action();}catch(const std::exception&){rejected=true;}
    if(!rejected)throw std::runtime_error(message);
}
}
int main() {
 try {
    check(parseMoney("12.3")==1230,"decimal money");
    check(formatMoney(5)=="0.05","leading fractional zero");
    for(const auto& value:{"","-1","1.001","NaN",".5","1.","1000000.01","999999999999999999999"})
        rejects([&]{parseMoney(value);},"invalid money accepted");
    CardService service;service.openStudent("S1","demo-s","Student");service.openStaff("T1","demo-t","Staff");
    check(service.cards().size()==2,"two cards");
    rejects([&]{service.openStudent("S1","duplicate","Other");},"duplicate card");
    rejects([&]{service.openStudent("","x","Name");},"empty id");
    rejects([&]{service.openStaff("T2","x","");},"empty holder");
    rejects([&]{service.openStaff("T3","x","   ");},"blank holder name");
    rejects([&]{service.card("missing");},"unknown card");
    service.topUp("S1",100000,"topup-s");service.topUp("T1",150000,"topup-t");
    auto first=service.pay("S1",50000,"pay-s1","2026-11-11");
    auto repeat=service.pay("S1",50000,"pay-s1","2026-11-11");
    check(first.balanceAfter==repeat.balanceAfter && service.history().size()==3,"idempotent payment");
    rejects([&]{service.pay("S1",1,"pay-s2","2026-11-11");},"student daily limit");
    check(service.card("S1").balance==50000 && service.history().size()==3,"rejection must not mutate");
    rejects([&]{service.pay("S1",200,"pay-s1","2026-11-11");},"id reused for another amount");
    service.pay("S1",50000,"pay-next-day","2026-11-12");
    rejects([&]{service.pay("S1",1,"empty-balance","2026-11-13");},"insufficient balance");
    service.pay("T1",100000,"pay-t1","2026-11-11");
    check(service.card("T1").balance==50000,"polymorphic staff limit");
    service.reportLost("T1");
    rejects([&]{service.pay("T1",1,"lost-pay","2026-11-12");},"lost card payment");
    rejects([&]{service.topUp("T1",1,"lost-topup");},"lost card topup");
    service.reactivate("T1");service.pay("T1",1,"reactivated","2026-11-12");
    for(const auto& day:{"2026-02-29","2026-13-01","2026-11-00","wrong"})
        rejects([&]{service.pay("T1",1,"bad-date",day);},"invalid day");
    rejects([&]{service.pay("T1",0,"zero","2026-11-12");},"zero amount");
    rejects([&]{service.pay("T1",-1,"negative","2026-11-12");},"negative amount");
    rejects([&]{service.topUp("T1",100000000,"overflow");},"balance limit");
    check(service.exportCsv().find("request_id,card_id")==0,"CSV header");
    check(service.exportCsv().find(",CNY\n")!=std::string::npos,"CSV currency");
    const auto before=service.history().size();
    for(int i=0;i<100;++i) service.topUp("S1",1,"small-"+std::to_string(i));
    check(service.card("S1").balance==100 && service.history().size()==before+100,"cent conservation");
    std::cout<<"PASS "<<cases<<" domain assertions\n";return 0;
 } catch(const std::exception& error) {std::cerr<<"FAIL "<<error.what()<<'\n';return 1;}
}
