#include "campus_window.hpp"
#include <QApplication>
#include <QComboBox>
#include <QDate>
#include <QFile>
#include <QFileDialog>
#include <QFormLayout>
#include <QHeaderView>
#include <QLabel>
#include <QLineEdit>
#include <QMainWindow>
#include <QMessageBox>
#include <QPushButton>
#include <QStatusBar>
#include <QTableWidget>
#include <QTimer>
#include <QUuid>
#include <QVBoxLayout>
#include <functional>
#include <iostream>
#include <stdexcept>

// 界面适配层只把用户输入交给服务，并在成功后刷新只读视图。
CampusWindow::CampusWindow(bool smoke) : smoke_(smoke) {
    setWindowTitle(QString::fromUtf8("校园一卡通 · GitEasy 教学项目"));
    resize(1060, 760);
    auto *center = new QWidget(this);
    auto *layout = new QVBoxLayout(center);
    auto *heading = new QLabel(QString::fromUtf8("校园一卡通业务管理"));
    heading->setStyleSheet("font-size:24px;font-weight:600;color:#155da6;margin-bottom:8px;");
    layout->addWidget(heading);
    layout->addWidget(
        new QLabel(QString::fromUtf8("教学演示 · 合成账户 · 业务数据仅保留于本次运行")));
    auto *form = new QFormLayout;
    id_ = new QLineEdit("S001");
    name_ = new QLineEdit(QString::fromUtf8("演示学生"));
    category_ = new QComboBox;
    category_->addItems({QString::fromUtf8("学生卡"), QString::fromUtf8("教工卡")});
    amount_ = new QLineEdit("20.00");
    form->addRow(QString::fromUtf8("卡号"), id_);
    form->addRow(QString::fromUtf8("持卡人"), name_);
    form->addRow(QString::fromUtf8("账户类型"), category_);
    form->addRow(QString::fromUtf8("金额（元）"), amount_);
    layout->addLayout(form);
    auto *actions = new QHBoxLayout;
    add_ = button(actions, "开卡", [this] {
        auto id = cardId();
        if (category_->currentIndex() == 0)
            service_.openStudent(id, id, name_->text().toStdString());
        else
            service_.openStaff(id, id, name_->text().toStdString());
    });
    topup_ = button(actions, "充值", [this] { service_.topUp(cardId(), money(), request()); });
    pay_ = button(actions, "消费", [this] { service_.pay(cardId(), money(), request()); });
    lost_ = button(actions, "挂失", [this] { service_.reportLost(cardId()); });
    restore_ = button(actions, "解挂", [this] { service_.reactivate(cardId()); });
    button(actions, "导出流水", [this] { exportCsv(); });
    layout->addLayout(actions);
    cards_ = new QTableWidget(0, 5);
    cards_->setHorizontalHeaderLabels({QString::fromUtf8("卡号"), QString::fromUtf8("持卡人"),
                                       QString::fromUtf8("类型"), QString::fromUtf8("余额（元）"),
                                       QString::fromUtf8("状态")});
    cards_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    cards_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    cards_->setSelectionBehavior(QAbstractItemView::SelectRows);
    layout->addWidget(cards_);
    ledger_ = new QTableWidget(0, 5);
    ledger_->setHorizontalHeaderLabels({QString::fromUtf8("卡号"), QString::fromUtf8("业务"),
                                        QString::fromUtf8("金额"), QString::fromUtf8("余额"),
                                        QString::fromUtf8("日期")});
    ledger_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    ledger_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    layout->addWidget(ledger_);
    connect(cards_, &QTableWidget::cellClicked, this,
            [this](int row, int) { id_->setText(cards_->item(row, 0)->text()); });
    center->setStyleSheet(
        "QPushButton{padding:8px 14px;background:#eaf4fa;border:1px solid #9abfd5;border-radius:4px;}QLineEdit,QComboBox{padding:5px;}QHeaderView::section{background:#e9f2f8;padding:5px;border:0;}QTableWidget{gridline-color:#dae4eb;}");
    setCentralWidget(center);
    statusBar()->showMessage(QString::fromUtf8("请先开卡，再充值和消费；金额按整数分存储。"));
}
std::string CampusWindow::cardId() const {
    return id_->text().trimmed().toStdString();
}
campus::Cents CampusWindow::money() const {
    return campus::parseMoney(amount_->text().trimmed().toStdString());
}
std::string CampusWindow::request() const {
    return QUuid::createUuid().toString(QUuid::WithoutBraces).toStdString();
}
QPushButton *CampusWindow::button(QHBoxLayout *row, const char *text,
                                  std::function<void()> action) {
    auto *result = new QPushButton(QString::fromUtf8(text));
    row->addWidget(result);
    connect(result, &QPushButton::clicked, this, [this, action] {
        try {
            action();
            refresh();
            lastError_.clear();
            statusBar()->showMessage(QString::fromUtf8("操作完成，账户和流水已更新。"));
        } catch (const std::exception &error) {
            lastError_ = QString::fromUtf8(error.what());
            statusBar()->showMessage(lastError_);
            if (!smoke_)
                QMessageBox::warning(this, QString::fromUtf8("业务拒绝"), lastError_);
        }
    });
    return result;
}
void CampusWindow::refresh() {
    const auto values = service_.cards();
    cards_->setRowCount(static_cast<int>(values.size()));
    for (int r = 0; r < static_cast<int>(values.size()); ++r) {
        const auto &value = values[r];
        const QStringList cells = {
            QString::fromStdString(value.cardId), QString::fromStdString(value.holderName),
            QString::fromStdString(value.category),
            QString::fromStdString(campus::formatMoney(value.balance)),
            value.state == campus::CardState::Active ? QString::fromUtf8("正常")
                                                     : QString::fromUtf8("已挂失")};
        for (int c = 0; c < cells.size(); ++c)
            cards_->setItem(r, c, new QTableWidgetItem(cells[c]));
    }
    const auto &history = service_.history();
    ledger_->setRowCount(static_cast<int>(history.size()));
    for (int r = 0; r < static_cast<int>(history.size()); ++r) {
        const auto &value = history[r];
        const QStringList cells = {QString::fromStdString(value.cardId),
                                   value.operation == campus::Operation::TopUp
                                       ? QString::fromUtf8("充值")
                                       : QString::fromUtf8("消费"),
                                   QString::fromStdString(campus::formatMoney(value.amount)),
                                   QString::fromStdString(campus::formatMoney(value.balanceAfter)),
                                   QString::fromStdString(value.day)};
        for (int c = 0; c < cells.size(); ++c)
            ledger_->setItem(r, c, new QTableWidgetItem(cells[c]));
    }
}
void CampusWindow::exportCsv() {
    const auto path = QFileDialog::getSaveFileName(this, QString::fromUtf8("导出业务流水"),
                                                   "campus-ledger.csv", "CSV (*.csv)");
    if (path.isEmpty())
        return;
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly))
        throw std::runtime_error("Cannot write export file");
    auto data = service_.exportCsv();
    if (file.write(data.data(), static_cast<qint64>(data.size())) !=
        static_cast<qint64>(data.size()))
        throw std::runtime_error("Incomplete export");
}
