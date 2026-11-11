# 第17章　校园一卡通系统版本管理实训

本章以[校园一卡通系统](../../projects/campus-card/README.md)完成C++11业务核心与Qt6图形界面的版本管理。项目可独立构建，提供成功和拒绝断言、交互测试，以及连续的本地双人开发演练。

## 阅读路径

- 项目背景、角色与迭代目标
- 阅读工程目录与构建入口
- 领域模型：封装、继承与多态
- 金额、请求与业务不变量
- Qt界面与可验证交互
- 开始连续实训的准备
- 将本地协作迁移到GitHub
- 发布与交接验收

## 实践

从GitEasy根目录运行：

```bash
python3 tools/run_enterprise_lab.py
```

19个连续命令块覆盖基线、并行开发、非快进拒绝、冲突、回归修复、维护拣选、autosquash、bisect、候选检查、归档、bundle恢复和worktree。需要Git、Bash、Python、CMake及C++编译器；Qt另按项目说明启用。实验在临时目录执行。

[架构与C++要点](../../projects/campus-card/docs/architecture.md) · [需求验收](../../projects/campus-card/docs/requirements.md) · [团队约定](../../projects/campus-card/docs/team-workflow.md) · [覆盖表](../../projects/campus-card/docs/git-skill-matrix.csv) · [交接模板](../../projects/campus-card/docs/handover-template.md)

## 习题与答案

[全部习题](exercises.md) · [逐题参考答案](answers.md)

[返回全书目录](../../README.md)

## 图解与练习升级

本章提供15道分层习题，最后一题为工程综合任务；[图解导读](./visual-guide.md)、[习题](./exercises.md)与[完整题意和解析](./answers.md)相互对应。
