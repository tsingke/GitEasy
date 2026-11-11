#include "campus/card_service.hpp"
#include <algorithm>
#include <chrono>
#include <ctime>
#include <iomanip>
#include <limits>
#include <sstream>
#include <utility>
namespace campus {
namespace {
const Cents MaxBalance = 100000000;
bool validDay(const std::string& text) {
    if (text.size()!=10 || text[4]!='-' || text[7]!='-') return false;
    for (std::size_t i=0;i<text.size();++i)
        if (i!=4 && i!=7 && (text[i]<'0' || text[i]>'9')) return false;
    int year=std::stoi(text.substr(0,4)), month=std::stoi(text.substr(5,2)), day=std::stoi(text.substr(8,2));
    if (year<1 || month<1 || month>12) return false;
    const int days[]={31,28,31,30,31,30,31,31,30,31,30,31};
    int maximum=days[month-1];
    if (month==2 && year%4==0 && (year%100!=0 || year%400==0)) ++maximum;
    return day>=1 && day<=maximum;
}
std::string csv(const std::string& value) {
    std::string result="\"";
    for (char ch : value) { if (ch=='\"') result+='\"'; result+=ch; }
    return result+'\"';
}
}
Cents parseMoney(const std::string& text) {
    if (text.empty()) throw std::invalid_argument("Amount is empty");
    Cents whole=0, fraction=0; bool dot=false; int digits=0, integerDigits=0;
    for (char ch : text) {
        if (ch=='.' && !dot) { dot=true; continue; }
        if (ch<'0' || ch>'9') throw std::invalid_argument("Use nonnegative decimal money");
        if (!dot) {
            ++integerDigits;
            if (whole > (MaxBalance/100-(ch-'0'))/10) throw std::out_of_range("Amount exceeds demo limit");
            whole=whole*10+(ch-'0');
        } else {
            if (++digits>2) throw std::invalid_argument("At most two decimal places");
            fraction=fraction*10+(ch-'0');
        }
    }
    if (integerDigits==0 || (dot && digits==0)) throw std::invalid_argument("Incomplete amount");
    if (digits==1) fraction*=10;
    const Cents result=whole*100+fraction;
    if (result>MaxBalance) throw std::out_of_range("Amount exceeds demo limit");
    return result;
}
std::string formatMoney(Cents amount) {
    if (amount<0) throw std::invalid_argument("Negative balance");
    std::ostringstream out;out<<amount/100<<'.'<<std::setw(2)<<std::setfill('0')<<amount%100;
    return out.str();
}
std::string today() {
    std::time_t now=std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    std::tm date=*std::localtime(&now);char buffer[11];
    if (!std::strftime(buffer,sizeof(buffer),"%Y-%m-%d",&date)) throw std::runtime_error("Clock formatting failed");
    return buffer;
}
CardHolder::CardHolder(std::string id,std::string name):id_(std::move(id)),name_(std::move(name)) {
    if (id_.find_first_not_of(" \t\r\n")==std::string::npos || name_.find_first_not_of(" \t\r\n")==std::string::npos) throw std::invalid_argument("Holder id and name are required");
}
void CardService::open(const std::string& id,std::unique_ptr<CardHolder> holder) {
    if (id.empty()) throw std::invalid_argument("Card id is required");
    if (cards_.count(id)) throw std::invalid_argument("Card already exists");
    std::unique_ptr<Card> value(new Card{id,std::move(holder),0,CardState::Active});
    cards_.emplace(id,std::move(value));
}
void CardService::openStudent(const std::string& id,const std::string& holder,const std::string& name) {
    open(id,std::unique_ptr<CardHolder>(new StudentHolder(holder,name)));
}
void CardService::openStaff(const std::string& id,const std::string& holder,const std::string& name) {
    open(id,std::unique_ptr<CardHolder>(new StaffHolder(holder,name)));
}
CardService::Card& CardService::requireCard(const std::string& id) {
    auto it=cards_.find(id);if(it==cards_.end()) throw std::out_of_range("Unknown card");return *it->second;
}
const CardService::Card& CardService::requireCard(const std::string& id) const {
    auto it=cards_.find(id);if(it==cards_.end()) throw std::out_of_range("Unknown card");return *it->second;
}
Transaction CardService::transact(const std::string& id,Cents amount,const std::string& request,
                                 Operation operation,const std::string& day) {
    if (amount<=0 || amount>MaxBalance) throw std::invalid_argument("Amount must be positive and within the demo limit");
    if (request.empty()) throw std::invalid_argument("Request id is required");
    if (!validDay(day)) throw std::invalid_argument("Day must be a real YYYY-MM-DD date");
    auto old=receipts_.find(request);
    if (old!=receipts_.end()) {
        const Transaction& receipt=old->second;
        if(receipt.cardId!=id || receipt.operation!=operation || receipt.amount!=amount || receipt.day!=day)
            throw std::invalid_argument("Request id conflicts with a different operation");
        return receipt;
    }
    Card& target=requireCard(id);
    if(target.state!=CardState::Active) throw std::logic_error("Card is reported lost");
    Cents next=target.balance;
    if(operation==Operation::TopUp) {
        if(amount>MaxBalance-next) throw std::out_of_range("Balance exceeds demo limit");
        next+=amount;
    } else {
        if(amount>next) throw std::logic_error("Insufficient balance");
        Cents spent=0;
        for(const auto& item:transactions_)
            if(item.cardId==id && item.operation==Operation::Payment && item.day==day) spent+=item.amount;
        if(amount>target.holder->dailyLimit()-spent) throw std::logic_error("Daily payment limit exceeded");
        next-=amount;
    }
    Transaction receipt{request,id,operation,amount,next,day};
    transactions_.push_back(receipt);
    try { receipts_.emplace(request,receipt); }
    catch (...) { transactions_.pop_back(); throw; }
    target.balance=next;
    return receipt;
}
Transaction CardService::topUp(const std::string& id,Cents amount,const std::string& request) {
    return transact(id,amount,request,Operation::TopUp,today());
}
Transaction CardService::pay(const std::string& id,Cents amount,const std::string& request,const std::string& day) {
    return transact(id,amount,request,Operation::Payment,day);
}
void CardService::reportLost(const std::string& id) { requireCard(id).state=CardState::Lost; }
void CardService::reactivate(const std::string& id) { requireCard(id).state=CardState::Active; }
CardView CardService::card(const std::string& id) const {
    const Card& item=requireCard(id);
    return CardView{item.id,item.holder->name(),item.holder->category(),item.balance,item.state};
}
std::vector<CardView> CardService::cards() const {
    std::vector<CardView> result;for(const auto& item:cards_) result.push_back(card(item.first));
    std::sort(result.begin(),result.end(),[](const CardView& a,const CardView& b){return a.cardId<b.cardId;});
    return result;
}
std::string CardService::exportCsv() const {
    std::ostringstream out;out<<"request_id,card_id,operation,amount,balance_after,day,currency\n";
    for(const auto& item:transactions_)
        out<<csv(item.requestId)<<','<<csv(item.cardId)<<','<<(item.operation==Operation::TopUp?"topup":"payment")
           <<','<<formatMoney(item.amount)<<','<<formatMoney(item.balanceAfter)<<','<<item.day<<",CNY\n";
    return out.str();
}
}
