# 对象模型与内容寻址：辅导材料

## 存储观察：压缩组织不改变逻辑对象
### 为什么需要打包
若每个新对象都以独立文件保存，随着项目增长，文件数量和访问开销可能增加。Git 可以把对象组织到 pack 中，并配套索引提高定位效率；部分对象还可能采用基于其他对象的差异表示。这些属于物理存储安排，不改变逻辑上通过标识访问对象的方式。

因此，“Git 保存快照”与“Git 使用差异压缩”并不矛盾。前者描述版本的逻辑内容模型，后者描述如何节约存储与传输。相似地，打包前后磁盘占用变化，并不意味着提交历史已经被整理或删除。

### 独立实验：打包前后核对对象身份
本实验创建几次具有相似内容的提交，记录提交与树的标识，然后执行一次显式重新打包。目的仅是观察对象查询接口保持一致，不比较不同硬件上的性能。


### 创建相似内容的连续版本

```bash
mkdir packing09
cd packing09
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
for number in 1 2 3 4; do
  printf 'Course note version %s\n' "$number" > note.txt
  git add note.txt
  git commit -m "docs: record note version $number"
done
COMMIT09=$(git rev-parse HEAD)
TREE09=$(git rev-parse HEAD^{tree})
BLOB09=$(git rev-parse HEAD:note.txt)
git count-objects -v
git repack -ad
git count-objects -v
```



### 验证逻辑对象与历史保持一致

```bash
test "$(git rev-parse HEAD)" = "$COMMIT09"
test "$(git rev-parse HEAD^{tree})" = "$TREE09"
test "$(git rev-parse HEAD:note.txt)" = "$BLOB09"
test "$(git rev-list --count HEAD)" = 4
git cat-file -p "$BLOB09"
git fsck --full
test -z "$(git status --porcelain)"
```


对象标识保持不变，是因为逻辑对象内容没有变化。`count-objects` 的统计可以帮助观察松散对象与包的组织，但具体数量和大小受版本、配置及维护状态影响，不应要求所有读者得到完全相同的字节数。

### 维护、回收与恢复不能混为一谈
重新打包主要调整存储组织；回收还涉及对象是否可达及保留条件；恢复则试图为需要的成果找到内容和入口。三项工作相关，却不具有相同目标。故障现场中先进行激进回收，可能削弱恢复线索，因此应先保全和诊断。

日常维护可以由 Git 的维护机制或平台运维安排执行。大型仓库还可能使用提交图、多个包的索引以及位图等辅助结构改善查询和传输。它们是加速用的数据结构，不是项目业务内容；生成或更新后仍应能通过正常接口访问同一逻辑历史。

### 对象数据库为什么不宜手工修改
直接编辑压缩对象文件不会像编辑普通文本那样产生有效新版本。对象标识、编码与引用关系必须一致，局部修改可能造成损坏。研究实现时应使用独立实验副本和专用命令，真实项目则通过高层工作流产生新对象。

本节练习：打包后发现对象目录中文件数减少，能否认定旧版本丢失？参考分析是不能。应查询目标提交、相关内容与完整性，而不是以目录中文件数量判断历史。物理布局是实现层线索，逻辑查询才直接对应用户需要访问的版本。
