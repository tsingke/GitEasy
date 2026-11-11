# 多文件架构与C++能力对应

先读[企业项目实施方案](enterprise-project-plan.md)确定范围、模块和验收，再按[任务迭代](iterations.md)开发。设计决定保存在[架构决策记录](decisions.md)，不能只在口头讨论中保留。

## 依赖方向

CLI和Qt窗口调用`CardService`；服务组合金额、日期、持卡人策略和流水报告模块。`campus_domain`保存基础实现，`campus_core`提供业务入口。基础头文件不包含Qt类型，核心与界面分别编译、分别验证。禁止通过包含`.cpp`拼接程序。

| 文件 | 责任 |
|---|---|
| `include/campus/types.hpp` | 整数分、枚举、查询视图与回执 |
| `money.hpp`、`src/money.cpp` | 十进制解析、格式化和金额边界 |
| `business_date.hpp`、`src/business_date.cpp` | 日期校验、系统日期与可注入提供器 |
| `card_holder.hpp`、`src/card_holder.cpp` | 身份封装、抽象接口与类别限额 |
| `ledger_export.hpp`、`src/ledger_export.cpp` | CSV报告与字段转义 |
| `card_service.hpp`、`src/card_service.cpp` | 余额、状态、限额、请求与一致性 |
| `gui/campus_window.hpp/.cpp` | 输入、按钮、调用、反馈与刷新 |
| `gui/main.cpp` | 应用与窗口组装 |
| `gui/smoke_scenario.cpp` | 实际按钮与模型、表格的一致性 |
| `tests/test_*.cpp` | 模块边界和业务集成的可执行判断 |

表中的基础模块头文件均位于`include/campus/`。实现先包含自己的接口，使依赖明确而不依赖偶然的包含顺序。

## C++11特性与真实职责

`CardHolder`定义类别和限额虚接口，`StudentHolder`、`StaffHolder`使用`override`提供不同策略。基类具有虚析构；`std::unique_ptr`与移动语义表达独占所有权。服务禁止复制，查询按值返回`CardView`，调用者不能绕过入口改余额。只读流水借用在服务继续写入时可能使既有迭代器失效。

`enum class`区分状态与操作；`auto`、范围for和lambda用于遍历、排序及回调；`DayProvider`以`std::function`承接日期依赖。测试可以注入固定日期，普通运行使用系统日期。没有把C++14的`make_unique`写为C++11特性。

## 不变量与测试

金额直接按字符解析为整数分。服务先校验并计算下一状态，再准备流水和回执；回执索引准备失败时撤回新流水，随后才更新余额。这说明单进程中的状态保护，不等价于数据库事务或线程安全。

基础模块测试与服务集成测试共用正式库。核心按C++11构建，Qt6目标按C++17构建。Qt使用已有QObject信号和lambda连接，不需要自定义`Q_OBJECT`元对象。交互冒烟场景在独立实现文件中执行真实按钮，核对服务状态和视图。

## 注释与变更

注释解释单位、职责、所有权、失败效果和跨模块约定；统一格式由`.clang-format`说明。教学定位标记供脚本构造可复现输入，不参与业务逻辑。格式调整、功能实现和缺陷修复应分别说明意图，用需求、差异和测试保留判断依据。
