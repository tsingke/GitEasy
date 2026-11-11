#ifndef CAMPUS_CARD_HOLDER_HPP
#define CAMPUS_CARD_HOLDER_HPP
#include "campus/types.hpp"
namespace campus {
// 抽象策略：服务通过基类接口读取类别和限额，不按界面标签判断身份。
class CardHolder {
  public:
    CardHolder(std::string id, std::string name);
    virtual ~CardHolder() = default;
    const std::string &id() const {
        return id_;
    }
    const std::string &name() const {
        return name_;
    }
    virtual std::string category() const = 0;
    virtual Cents dailyLimit() const = 0;

  private:
    std::string id_;
    std::string name_;
};
class StudentHolder : public CardHolder {
  public:
    using CardHolder::CardHolder;
    std::string category() const override {
        return "Student";
    }
    Cents dailyLimit() const override {
        return 50000;
    }
};
class StaffHolder : public CardHolder {
  public:
    using CardHolder::CardHolder;
    std::string category() const override {
        return "Staff";
    }
    Cents dailyLimit() const override {
        return 100000;
    }
};
} // namespace campus
#endif
