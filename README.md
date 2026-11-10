<p align="center"><img src="assets/book-cover.png" width="240" alt="Git版本控制原理与实践封面"></p>

# GitEasy · Git版本控制原理与实践

[![Textbook labs](https://github.com/tsingke/GitEasy/actions/workflows/labs.yml/badge.svg)](https://github.com/tsingke/GitEasy/actions/workflows/labs.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-087F78.svg)](./LICENSE)

**从第一次提交，到能够解释、验证和交接的工程协作。**

张庆科《Git版本控制原理与实践》配套教学项目。全书按基础、核心、进阶、实践四篇组织；本仓库提供16章辅导材料、原创知识结构图、可复现实验、分层练习和综合项目种子。无需平台账号即可完成离线实验。

## 快速开始

需要Git、Bash与Python 3.9及以上版本。签名与依赖实验另需OpenSSH和Git subtree，具体范围见[学习说明](./docs/learning-guide.md)。

```bash
git clone https://github.com/tsingke/GitEasy.git
cd GitEasy
python3 tools/run_lab.py --chapter 02
python3 tools/run_lab.py --all --list
```

运行器在临时目录建立练习仓库，结束后清理现场，日志另存到证据目录。所有路线只访问本地仓库。手工学习请先阅读本章说明，预测状态再逐块操作。

## 全书导航

| 篇 | 章 | 章节与资源 | 学习重点 |
|---|---:|---|---|
| 基础篇 | 01 | [版本控制与Git基础](./chapters/ch01-版本控制与Git基础/README.md) | 记录与历史边界 |
| 基础篇 | 02 | [环境配置与仓库初始化](./chapters/ch02-环境配置与仓库初始化/README.md) | 目录、配置、首次提交 |
| 基础篇 | 03 | [工作区、索引与提交](./chapters/ch03-工作区、索引与提交/README.md) | 候选内容与文本规则 |
| 基础篇 | 04 | [历史查询与版本溯源](./chapters/ch04-历史查询与版本溯源/README.md) | 查询、范围、二分与批注 |
| 核心篇 | 05 | [分支与HEAD](./chapters/ch05-分支与HEAD/README.md) | 入口、切换与分离状态 |
| 核心篇 | 06 | [合并原理与冲突处理](./chapters/ch06-合并原理与冲突处理/README.md) | 三方、语义与重复冲突 |
| 核心篇 | 07 | [远程仓库与协作](./chapters/ch07-远程仓库与协作/README.md) | 观察记录、映射与交换 |
| 核心篇 | 08 | [变更撤销与版本恢复](./chapters/ch08-变更撤销与版本恢复/README.md) | 保留目标与恢复条件 |
| 进阶篇 | 09 | [对象模型与内容寻址](./chapters/ch09-对象模型与内容寻址/README.md) | 内容寻址、复用与存储 |
| 进阶篇 | 10 | [引用管理与索引机制](./chapters/ch10-引用管理与索引机制/README.md) | 名称、索引与条件更新 |
| 进阶篇 | 11 | [变基、拣选与历史整理](./chapters/ch11-变基、拣选与历史整理/README.md) | 重放、移植与补丁协作 |
| 进阶篇 | 12 | [版本标记、签名与发布](./chapters/ch12-版本标记、签名与发布/README.md) | 版本、归档与信任 |
| 实践篇 | 13 | [团队工作流与代码评审](./chapters/ch13-团队工作流与代码评审/README.md) | 需求、评审与合入策略 |
| 实践篇 | 14 | [仓库规模、依赖管理与多工作树](./chapters/ch14-仓库规模、依赖管理与多工作树/README.md) | 范围、依赖与并行目录 |
| 实践篇 | 15 | [自动化、安全与备份恢复](./chapters/ch15-自动化、安全与备份恢复/README.md) | 检查对象、备份与迁移 |
| 实践篇 | 16 | [综合项目实训](./chapters/ch16-综合项目实训/README.md) | 需求到独立交接 |

## 看得见，也能验证

![工作区、索引与提交的知识结构](./assets/mindmaps/ch03.png)

16张知识结构图分别对应章末复习，采用六色分支与可缩放源文件。[Draw.io源文件](./assets/git-book-mindmaps.drawio)可继续编辑，图片用于快速浏览。

主实验覆盖分支保护、增删冲突、双人交换、恢复矩阵、对象构造、变基、签名、依赖、钩子和综合交付；独立拓展覆盖换行属性、notes、rerere、refspec、打包、补丁和迁移。脚本将预期失败与最终验收区分，保留内容及历史断言。

## 综合项目

[course目录](./course/README.md)提供课程资料种子、初始化器、工作区与索引检查器、报告模板及知识覆盖登记表。完成个人记录、双人协作、整理发布、工程治理和独立交接；每个项目提交结果、过程与解释证据。

## 验证与维护

```bash
python3 tools/check_materials.py
python3 tools/run_lab.py --all
```

[实际验证记录](./docs/verification.json)保存已执行环境和路线结果；[CI](https://github.com/tsingke/GitEasy/actions/workflows/labs.yml)提供独立Linux/macOS运行记录。Windows、LFS服务、真实平台权限与人工评审不包含在离线通过结论中。

- [学习与实验说明](./docs/learning-guide.md)
- [贡献与勘误](./CONTRIBUTING.md)
- [参考资料与原创说明](./docs/references.md)
- [MIT许可证](./LICENSE)

本项目关注可迁移的理解：明确状态，解释关系，选择合适操作，用证据验证结果。
