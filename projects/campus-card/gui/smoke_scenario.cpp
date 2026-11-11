#include "campus_window.hpp"
#include <QLineEdit>
#include <QPushButton>
#include <QTableWidget>
#include <iostream>
#include <stdexcept>
// 按钮点击、服务状态和两张表同时验证，避免只检查窗口能否启动。
void CampusWindow::runSmokeTest() {
    add_->click();
    amount_->setText("100.00");
    topup_->click();
    amount_->setText("23.50");
    pay_->click();
    if (service_.card("S001").balance != 7650 || cards_->rowCount() != 1 ||
        ledger_->rowCount() != 2)
        throw std::runtime_error("GUI actions did not update model and tables");
    lost_->click();
    lastError_.clear();
    pay_->click();
    if (lastError_.isEmpty() || service_.history().size() != 2)
        throw std::runtime_error("Lost-card action was not rejected");
    restore_->click();
    pay_->click();
    if (service_.card("S001").balance != 5300 || ledger_->rowCount() != 3)
        throw std::runtime_error("Reactivation failed");
    std::cout << "PASS Qt GUI interaction smoke test\n";
}
