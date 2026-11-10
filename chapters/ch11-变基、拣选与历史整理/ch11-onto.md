# 变基、拣选与历史整理：辅导材料

## 范围重放实训：移除已经不再需要的中间依赖
### 先画清楚原有关系
一个主题最初从另一个试验分支开始，后来发现自己的变化并不依赖该试验功能，准备直接提交给主线。这时要同时回答三个问题：以哪里作为新基线，排除到哪个旧边界，以及移动哪条任务分支。`--onto` 的价值在于把这些角色分别表达，而不是让一个参数承担全部含义。

本例中，main 是稳定起点；helper 增加一份无关试验说明；topic 从 helper 继续增加练习。最终希望 topic 只把自己的练习重放到 main，避免让 helper 的说明进入主题结果。实验特意使用互不依赖的文件，使排除中间变化具有合理业务前提。


### 构造具有中间基线的主题

```bash
mkdir onto11
cd onto11
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '# Stable course\n' > README.md
git add README.md
git commit -m "docs: establish the stable course"
git switch -c helper
printf 'Optional helper material\n' > helper.txt
git add helper.txt
git commit -m "docs: add the helper material"
git switch -c topic
printf 'Exercise: inspect the staged content.\n' > exercise.txt
git add exercise.txt
git commit -m "docs: add an independent exercise"
git branch backup/topic-with-helper
git log --oneline --graph --all
```


此时 topic 的历史包含 helper 提交，因此若直接快进主线，就会同时接收中间说明。只比较 topic 最新提交的说明不足以识别范围；应查看从主线到主题的整个可达差异。


### 选择主题独有范围，在主线基线上重放

```bash
git log --oneline helper..topic
git rebase --onto main helper topic
git log --oneline --graph --all
test -f exercise.txt
test ! -e helper.txt
git merge-base --is-ancestor main topic
if git merge-base --is-ancestor helper topic; then exit 1; fi
test -z "$(git diff backup/topic-with-helper topic -- exercise.txt)"
test "$(git rev-list --count main..topic)" = 1
```


本例所选择的是 topic 中排除 helper 可达部分后的提交。新结果仍有练习文件，却没有 helper 文件；main 是新主题的祖先，而 helper 不是。备份入口保留原关系，便于比较与恢复。相关选项与选择范围的复杂情形，应结合官方变基手册核对（参见仓库根目录的参考资料）。

### 范围正确仍需检查依赖
如果练习实际引用 helper 文件中的内容，机械排除 helper 就会得到不完整成果。文本重放可能成功，但语义已经破坏。因此重放以后必须检查文件关系、链接和测试，不能只看“成功变基”的提示。

复杂历史含合并提交、等价补丁或其他特殊条件时，选择和重放行为还会受到相应选项影响。初学者应先在简单线性例子中建立范围模型，再处理复杂图。不要把本例的三个名称替换到任意历史，就期待保持同样效果。

### 怎样审阅重放结果
审阅分为范围、内容和连接三个层次。范围检查确认只重放预期提交；内容检查确认主题意图保留且无缺失依赖；连接检查确认新基线和父关系符合要求。必要时比较原、新提交序列，并解释冲突处理所引入的变化。

迁移练习：让 helper 成为 topic 的真实依赖，再思考是否仍应排除它。参考分析应根据需求重新选择：保留依赖、拆出必要部分，或先完成独立化改造。`--onto` 提供历史变换能力，是否应该这样变换仍由项目约束决定。
