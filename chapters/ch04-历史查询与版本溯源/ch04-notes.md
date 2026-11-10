# 历史查询与版本溯源：辅导材料

## 内容检索与附加说明
### grep检索内容，log检索变化
如果问题是“当前版本哪些文件含有某个术语”，应从内容搜索开始；如果问题是“这个术语何时加入或删除”，则要检索历史变化。两类任务虽然都可能包含关键词，却具有不同输入和输出。`git grep` 可以在指定内容范围中搜索文本，历史查询则沿提交关系筛选变化。

在大项目中，先限定目录或文件类型通常更有效。需要引用结果时，应同时记录版本与路径，避免只给当前行号。行号会随编辑变化，而提交与路径组合能够为读者提供更稳定的重现入口。

### 独立实验：同一关键词在两个版本中的位置
以下实验先创建一份说明，再把相同概念转移到另一文件。它用于说明当前搜索结果与历史变更线索之间的区别。


### 建立可搜索的两个版本

```bash
mkdir search04
cd search04
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
mkdir docs
printf 'Index: candidate content for the next commit.\n' > README.md
git add README.md
git commit -m "docs: define the index briefly"
printf '# Course guide\n' > README.md
printf 'Index: candidate content for the next commit.\n' > docs/index.txt
git add README.md docs/index.txt
git commit -m "docs: move the index definition into the guide"
git grep -n -F 'candidate content' HEAD -- README.md docs
git grep -n -F 'candidate content' HEAD^ -- README.md docs
git log --oneline -S 'candidate content' -- README.md
```


两个版本都包含相同句子，但路径发生变化。搜索指定树中的内容，可以得到该版本的实际位置；沿 README.md 查询相关文本数量变化，则能看到定义的加入和移出。两类证据互补，不应把一次搜索结果当作完整历史。

### notes为已有对象附加说明
有时需要为一个已发布提交补充教学批注，又不希望重写原提交信息。Git notes 可以在独立的 notes 引用下记录附加说明。原提交对象保持不变，附加内容则需要作为另一类数据管理和交换（参见仓库根目录的参考资料）。


### 附加一条复核说明，并验证原提交未改写

```bash
ORIGINAL04=$(git rev-parse HEAD)
git notes add -m "Teaching review: definition moved without changing its wording."
git notes show HEAD
test "$(git rev-parse HEAD)" = "$ORIGINAL04"
git log -1 --show-notes
git show-ref refs/notes/commits
```


附加说明不会自动进入普通文件树，也不能假定所有克隆默认交换全部 notes。若团队依赖它，应明确获取与推送范围，以及不同成员同时修改时怎样整合。对于必须随普通资料分发的说明，直接写入版本化文档可能更容易被读者发现。

### 检索结果的引用规范
教材、实验报告和问题单引用仓库内容时，至少给出提交标识、路径和所观察的范围。平台的分支链接方便浏览，但随着分支移动，其内容可能变化；固定提交链接更适合说明一次已经完成的调查。敏感仓库中还应考虑接收者是否具有访问权限。

本节练习：为“术语定义在哪一版发生变化”设计调查过程。参考分析应先搜索当前和目标版本，再查看相关补丁，最后记录变化理由。若文字只是从一个文件移动到另一个文件，报告不应错误地声称概念已被删除。
