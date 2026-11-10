# 自动化、安全与备份恢复：辅导材料

## 仓库迁移：把数据、平台资料与服务配置分开
### 迁移的对象不只是一个地址
团队从一项托管服务迁移到另一项服务时，修改远端地址只是访问配置变化。完整迁移还需要考虑分支、标签、外部大文件、子模块地址、需求单、评审、自动化、部署密钥和访问规则。普通 Git 数据交换只能覆盖其中一部分。

迁移计划应先列清单，再为每类内容选择导出、复制、重新配置或归档方式。尤其是外部对象与平台元数据，不能因为主仓库克隆成功就假定已经迁移。正式切换前还应安排写入冻结窗口或明确增量同步方式，避免新旧两端同时前进却无人负责整合。

### 独立实验：在空目标中验证镜像范围
镜像操作会涉及广泛引用，适合在完全独立、明确为空的目标中学习。以下全部路径均为新建教学仓库。实验先创建主线、任务分支与附注标签，再镜像到另一裸仓库，并比较公开引用。


### 准备源仓库与空目标

```bash
mkdir migration15
cd migration15
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '# Migration exercise\n' > README.md
git add README.md
git commit -m "docs: establish the migration exercise"
git branch feature/guide
git tag -a course-v1.0.0 -m "First migration checkpoint"
cd ..
git clone --mirror migration15 migration15-mirror.git
git init --bare --initial-branch=main migration15-target.git
git -C migration15-mirror.git push --mirror ../migration15-target.git
```



### 比较源与目标的引用，并从目标重新取得内容

```bash
git -C migration15 for-each-ref \
  --format='%(refname) %(objectname)' refs/heads refs/tags > source15-refs.txt
git --git-dir=migration15-target.git for-each-ref \
  --format='%(refname) %(objectname)' refs/heads refs/tags > target15-refs.txt
cmp source15-refs.txt target15-refs.txt
git clone migration15-target.git migration15-reader
git -C migration15-reader fsck --full
git -C migration15-reader show course-v1.0.0:README.md
```


比较的是实验指定的分支与标签引用，不是平台的一切数据。目标仓库的默认分支设置、权限和工作流仍须另行检查。镜像推送还可能强制更新或删除目标引用，绝不能将本实验命令不加判断地用于已经承载其他工作的重要目标。

### 切换以后仍需验证新成员路径
迁移成功的验收应从新地址开始，使用正常协作者权限取得仓库，初始化依赖，运行检查并尝试受控任务。维护者管理员账号下的成功不能代表普通成员也具备所需权限。自动化密钥与令牌应采用新服务的授权流程，避免把旧凭据作为普通文件复制。

若旧地址继续提供只读归档，应明确说明新写入入口；若依赖地址发生变化，应检查版本化配置与文档。迁移公告可以指向固定版本和迁移说明，帮助后来者理解历史链接为何变化。

### 回退计划与完成标准
切换前应约定出现何种问题时暂缓或回退，以及在切换窗口内产生的新提交怎样处理。不能简单把地址改回去，就假定新目标上的工作自动回到旧目标。回退本身也是一次数据协调任务，需要保留双方引用和实际写入记录。

迁移练习：为课程仓库设计一份包含 Git 对象、LFS、子模块、评审记录和 CI 设置的清单。每项写出负责人、保存方式、验证依据和未覆盖内容。评价重点是边界完整与步骤可执行，而不是追求一个看似通用的“一键迁移”命令。
