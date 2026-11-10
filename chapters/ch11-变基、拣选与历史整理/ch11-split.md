# 变基、拣选与历史整理：辅导材料

## 提交拆分实训：让两项任务分别接受评审
### 拆分的目标与限制
一个尚未共享的提交同时增加了地点说明和阅读建议，维护者希望分别评审。拆分需要让两项变化成为独立提交，同时保持最终文件树。若该提交后面还有其他提交，通常应通过交互式整理在指定位置暂停；下面先研究“最近提交尚未共享”的最小情形。

操作前保存原入口并确认工作区干净。使用 mixed 重置以后，分支与索引回到父位置，工作文件仍保留原最终内容。随后按任务重新选择候选，形成两项提交。该路线需要理解保留目标，不能作为处理任意共享历史的通用步骤。


### 建立含两项任务的最近提交

```bash
mkdir split11
cd split11
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '# Course baseline\n' > README.md
git add README.md
git commit -m "docs: establish the baseline"
printf 'Room: A101\n' > room.txt
printf 'Read the candidate diff.\n' > reading.txt
git add room.txt reading.txt
git commit -m "docs: add room and reading information"
git branch backup/before-split
ORIGINAL_TREE11=$(git rev-parse HEAD^{tree})
test -z "$(git status --porcelain)"
```



### 保留文件内容，重新组织两项提交

```bash
git reset --mixed HEAD^
git status --short
git add room.txt
git diff --cached --name-only
git commit -m "docs: record the course room"
git add reading.txt
git diff --cached --name-only
git commit -m "docs: add the reading reminder"
test "$(git rev-parse HEAD^{tree})" = "$ORIGINAL_TREE11"
test "$(git rev-list --count HEAD)" = 3
test "$(git diff HEAD~2 HEAD~1 --name-only)" = room.txt
test "$(git diff HEAD~1 HEAD --name-only)" = reading.txt
test -z "$(git status --porcelain)"
```


两项新提交替代原混合提交，但备份入口仍保留旧版本。最终树相同，证明端点内容没有因拆分遗漏；逐项补丁范围不同，证明评审边界已经形成。若两项任务实际必须同时生效，则还要考虑中间版本是否合理，不能机械追求拆分。

### 把方法放入交互式整理
对较早的混合提交，可在交互式变基计划中标记 edit，暂停后按相同模型拆分，再继续重放后续提交。此时还应验证后续变化在新序列中仍可应用且保持意图。暂停位置、当前提交与整个操作的起点必须分别记录。

如果拆分发生冲突或发现依赖，应保留现场重新分析。中止与继续对应不同决定，不能为了让流程走完而跳过无法理解的变化。公共历史的整理还需要协作迁移，不因本地实验成功而自动获得适用性。

### 拆分之后的说明与验证
每项新提交应表达完整目的，并附带相应测试或资料核对。若第一项暂时不能运行，只能依赖第二项才成立，应重新考虑边界，或在项目约定允许时明确中间状态。历史整理应服务于后续阅读、回退和排查，而不是仅满足形式上的细分。

本节任务是把一个包含三类无关修改的教学提交拆分，并写出最终树和每项补丁的证据。报告还应说明原提交是否共享、旧入口保留在哪里，以及哪些检查只能证明端点内容、哪些能够证明中间序列。
