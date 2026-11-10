# 变基、拣选与历史整理：辅导材料

## 补丁协作：在仓库连接之外交换变化
### 补丁为什么仍然有用
协作者未必总能直接访问同一托管平台。代码评审、邮件协作或受限环境中，变化可以先表示为补丁文件，再由接收者检查并应用。补丁的价值在于交换变化，而不是提供仓库的完整备份。接收者仍需知道补丁针对什么基线、按什么顺序应用，以及应用以后怎样验证。

普通差异补丁主要描述内容变化；由 `format-patch` 导出的邮件格式补丁还包含用于重建提交的作者、说明等信息。`apply` 与 `am` 因此服务于不同层次：前者应用补丁内容，后者从邮件格式材料形成提交序列。具体选项、失败状态和三方应用前提应查阅官方手册（参见仓库根目录的参考资料）。

### 独立实验一：检查补丁，再应用内容
本例先从一次未提交编辑导出普通补丁，再恢复工作文件，最后检查并应用同一补丁。恢复动作只发生在专用实验目录，目的是让输入基线保持一致。


### 导出一项尚未提交的变化

```bash
mkdir patch11
cd patch11
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Room: A101\n' > room.txt
git add room.txt
git commit -m "docs: establish the patch baseline"
printf 'Room: B202\n' > room.txt
git diff --binary > ../room11.patch
git restore -- room.txt
git apply --stat ../room11.patch
git apply --check ../room11.patch
git apply ../room11.patch
```


`--stat` 帮助观察变化范围，`--check` 先判断补丁能否按当前条件应用，真正的应用随后才发生。检查通过不保证项目语义正确，也不能保证在检查与应用之间发生其他修改时结果仍然相同。


### 验证内容变化没有自动形成提交

```bash
grep -q 'Room: B202' room.txt
test "$(git rev-list --count HEAD)" = 1
test -z "$(git diff --cached)"
git diff -- room.txt
git add room.txt
git commit -m "fix: apply the corrected room patch"
```


普通应用后，工作文件改变，索引仍需按目标选择，提交也需要明确创建。读者不能因为补丁文件中包含完整路径和差异，就把它当作已经进入历史的一项提交。

### 独立实验二：用邮件格式交换一个提交
接续本节实验，以当前主线建立主题分支，创建一个新说明提交，再导出邮件格式。接收分支从同一基线开始，以 `am` 接收这项变化。


### 导出主题提交，并在另一分支接收

```bash
git branch receive-base
git switch -c mail-topic
printf 'Inspect the patch before applying it.\n' > review.txt
git add review.txt
git commit -m "docs: add a patch review reminder"
SOURCE11=$(git rev-parse HEAD)
git format-patch -1 --stdout HEAD > ../lesson11.mbox
git switch -c mail-receiver receive-base
git am ../lesson11.mbox
git show HEAD:review.txt
git log -1 --format='%an <%ae>%n%s'
test -z "$(git diff mail-topic mail-receiver)"
test -z "$(git status --porcelain)"
```


这里验证的是接收后文件树与主题结果一致，并观察作者及说明。新提交的标识可能与源提交相同，也可能因提交者时间等元数据不同而变化，不能把“必须不同”作为本例的通用断言。真正需要检查的是内容、顺序、来源信息和适用基线。

### 失败时保留操作语境
补丁应用失败可能来自基线差异、路径变化或上下文不匹配。应先查看失败位置和当前状态，再决定手工调整、使用满足前提的三方处理，或中止接收。不要为了消除报错而删除不理解的补丁片段。

`am` 的继续、跳过和中止分别具有不同含义。继续表示已经处理当前问题并准备形成相应提交；跳过表示不接收当前项；中止则返回操作前的相应状态。选择前应确认当前项的业务目的是否仍需要保留。

### 来源、许可与签署说明
接收补丁不仅要检查技术效果，还要遵守项目贡献规则和许可要求。作者字段描述提交元数据，签署说明可能表达项目约定，密码学签名又属于另一种验证机制。三者不能仅因都包含姓名或邮箱就相互替代。

迁移练习：将课程资料的一项修正导出为普通补丁和邮件格式补丁，说明接收者分别需要做哪些动作。报告应指出哪种材料直接支持重建提交、哪些内容仍须人工审核，以及何时应选择完整仓库或 bundle 进行交换。
