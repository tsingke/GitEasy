#ifndef CAMPUS_WINDOW_HPP
#define CAMPUS_WINDOW_HPP
#include "campus/card_service.hpp"
#include <QMainWindow>
#include <QString>
#include <functional>
class QLineEdit;
class QComboBox;
class QTableWidget;
class QPushButton;
class QHBoxLayout;
// QObject父子关系负责控件生命期；业务状态由独立的CardService管理。
class CampusWindow : public QMainWindow {
  public:
    explicit CampusWindow(bool smoke = false);
    // 教学检查使用真实按钮；实现独立于界面布局文件。
    void runSmokeTest();

  private:
    std::string cardId() const;
    campus::Cents money() const;
    std::string request() const;
    QPushButton *button(QHBoxLayout *row, const char *text, std::function<void()> action);
    void refresh();
    void exportCsv();
    bool smoke_;
    QString lastError_;
    campus::CardService service_;
    QLineEdit *id_, *name_, *amount_;
    QComboBox *category_;
    QTableWidget *cards_, *ledger_;
    QPushButton *add_, *topup_, *pay_, *lost_, *restore_;
};
#endif
