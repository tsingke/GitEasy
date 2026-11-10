# GitEasy 教学实训配套资源

本目录为教材综合实训提供离线起点，与各章辅导材料共同使用。线上仓库入口为 [tsingke/GitEasy](https://github.com/tsingke/GitEasy)。

需要 Git、Bash 或兼容 shell；工具脚本需要 Python 3.9 及以上版本。教材命令中的 `python3` 应替换为本机可用的 Python 命令。Windows 读者可在 Git Bash 中运行 shell 步骤。

## 建立离线起点

在本目录运行以下命令，`course-project` 必须不存在：

```bash
python3 tools/init_course.py /your/new/path/course-project
cd /your/new/path/course-project
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
git add .
git diff --cached --stat
git commit -m "docs: establish course materials"
git tag course-start
```

不要对已有作业目录重复运行初始化脚本。脚本只复制资料，不创建 Git 历史，也不访问网络。路径中的 `/your/new/path` 必须自行替换。

## 检查范围

在新仓库中运行检查器的绝对路径：

```bash
python3 /path/to/course/tools/check_course.py --repo .
python3 /path/to/course/tools/check_course.py --repo . --index
```

第一条检查工作区，第二条读取索引中的五个必需文档。检查内容仅包括文件可读取、UTF-8、首行标题、疑似冲突标记及末尾换行；索引模式还拒绝未合并条目。它不证明课程安排正确，不检查全部链接、全部 Markdown 文件或程序安全性。形如七个等号的独立行也会被保守地判为疑似冲突标记，实验资料统一采用 `#` 标题。

以 `--index` 检查时，在仓库根目录运行。部分暂存时，工作区通过而索引失败是合理结果。修复后需要重新暂存相应文件。检查器本身位于分发资源中，实验种子没有复制该脚本；教师如希望把它纳入项目，须明确复制、提交并调整调用路径。

## 学生交付清单

1. 记录 Git 版本、仓库起点和当前目录。
2. 个人项目：两次独立提交、候选差异、按路径与内容检索结果。
3. 协作项目：Alice/Bob 独立成果、非快进拒绝、冲突三方内容、双亲合并及共享结果。
4. 发布项目：整理前后的树、维护分支修复、附注标签、归档清单。
5. 治理项目：检查正反例、bundle 恢复及未覆盖数据；扩展环境不足时如实标注未执行。
6. GitHub 项目：自己的 fork 与上游方向、实际评审和响应证据；本地模拟须清楚标注。

详细任务和解析见教材第 16 章。自动验证仅验证教材指定的离线实例，不能代替学生自己的实验，也没有验证线上权限、分支保护或 Release。

## 可直接使用的教学文件

- `report-template.md`：学生实验报告，要求记录前提、预期失败、检查对象和恢复边界。
- `知识覆盖与证据登记.csv`：24 项知识领域与项目任务映射，状态初始为“待执行”，由学生填写真实证据。
- `examples/pull_request_template.md`：贡献说明模板；可按课程项目需要复制到 `.github` 对应位置。
- `examples/course-check.yml`：第 15 章相同的 CI 配置示例。须先把检查器复制到实验仓库的 `tools/check_course.py`，并准备根目录的五份必需资料，再放入 `.github/workflows`。该文件是课程资料仓库的示例，与本项目运行范例脚本的 labs.yml 工作流用途不同。
