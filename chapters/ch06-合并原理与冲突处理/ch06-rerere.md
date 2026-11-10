# 合并原理与冲突处理：辅导材料

## 重复冲突的处理记录与复用
### 为什么会反复遇到同一类冲突
长时间维护的主题分支可能多次与主线整合，或者在试验不同整理方案时反复遇到相近冲突。若每次都从头编辑，不仅耗时，也容易在重复劳动中引入不一致。Git 的 rerere 机制可以记录某些冲突的解决方式，并在以后匹配到相应情境时复用（参见仓库根目录的参考资料）。

复用不代表解决结果永远正确。项目语义可能已经变化，先前选择也可能存在错误。因此建议把自动复用的内容看作待复核候选，重新检查文件和测试，再决定是否暂存。尤其在学习阶段，不宜让自动更新索引掩盖观察过程。

### 独立实验：先解决，再重复同一合并
本实验在新仓库启用记录，关闭自动更新索引，并保留整合前入口。第一次产生冲突后写入明确结果，再回到整合前位置重做同一合并。所有重置仅针对本实验仓库。


### 构造并记录第一次冲突解决

```bash
mkdir repeated06
cd repeated06
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
git config rerere.enabled true
git config rerere.autoupdate false
printf 'Room: A101\n' > room.txt
git add room.txt
git commit -m "docs: establish the baseline room"
git switch -c topic
printf 'Room: B202\n' > room.txt
git add room.txt
git commit -m "docs: propose room B202"
git switch main
printf 'Room: C303\n' > room.txt
git add room.txt
git commit -m "docs: propose room C303"
git branch before-integration
if git merge topic; then exit 1; fi
git rerere status
printf 'Room: D404, confirmed by the instructor.\n' > room.txt
git rerere
git add room.txt
git commit -m "merge: use the confirmed room D404"
```


第一次解决采用第三种明确确认的结果，而不是机械保留某一方。执行 `rerere` 记录解决后，仍由作者暂存并提交。这使内容决定与记录机制保持清楚的先后关系。


### 重复整合，检查复用内容与未合并索引

```bash
git reset --hard before-integration
if git merge topic; then exit 1; fi
grep -q 'Room: D404' room.txt
test -n "$(git ls-files -u)"
git diff -- room.txt
git add room.txt
git commit -m "merge: review and accept the reused resolution"
test -z "$(git status --porcelain)"
```


再次合并时，工作文件可以出现已记录的解决内容，但因为关闭自动索引更新，仍需检查未合并条目并明确暂存。合并命令报告冲突退出，并不妨碍记录机制把候选解决写入工作文件；退出状态与当前文件状态需要分别观察。

### 错误记录如何处理
若先前解决已经不适用，应先依据当前需求修正，再按手册选择忘记相应记录等操作。不能因为复用了历史方案就跳过评审。对于并非重复冲突的全新情境，机制也不保证能够匹配或生成正确答案。

本节迁移任务是解释：为什么“工作文件已没有冲突标记”仍不足以证明合并完成？参考分析应同时讨论索引状态、项目语义与提交状态。rerere 的价值在于减少重复编辑，使维护者有更多时间审阅决定，而不是代替维护者作决定。
