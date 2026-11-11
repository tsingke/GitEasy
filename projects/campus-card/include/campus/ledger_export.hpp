#ifndef CAMPUS_LEDGER_EXPORT_HPP
#define CAMPUS_LEDGER_EXPORT_HPP
#include "campus/types.hpp"
#include <vector>
namespace campus {
// 只生成报告文本，不写磁盘、不修改流水，也不承担状态恢复。
std::string exportLedgerCsv(const std::vector<Transaction> &transactions);
} // namespace campus
#endif
