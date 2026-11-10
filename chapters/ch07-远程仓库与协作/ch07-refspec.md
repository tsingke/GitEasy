# 远程仓库与协作：辅导材料

## 交换范围：从远端简称到引用映射
### refspec回答来源与去向
仓库之间交换提交时，不仅需要知道连接地址，还要决定哪些引用参与交换，以及在接收方使用什么名称。refspec 用于表达这种映射。理解映射以后，读者就能解释为什么服务器上的 `refs/heads/main` 在本地通常表现为 `refs/remotes/origin/main`，而不是自动覆盖本地 main。

常见获取配置采用通配映射，将一组服务器分支记录到对应的远程跟踪命名空间。前缀加号表示该映射允许特定非快进更新，并不意味着服务器上的所有引用都会被取得，也不意味着本地工作文件随之改变。具体语法与限制应结合 fetch、push 和相关协议手册阅读（参见仓库根目录的参考资料）。

### 独立实验：只获取一个明确分支
本实验先建立两个服务器分支，再让观察者仅获取其中一个。它把网络传输替换为本地路径，使读者专注于引用映射。


### 准备包含主线与实验分支的服务器

```bash
git init --bare --initial-branch=main selective07.git
mkdir producer07
cd producer07
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Main course\n' > README.md
git add README.md
git commit -m "docs: establish the main course"
git switch -c experiment
printf 'Optional experiment\n' > optional.txt
git add optional.txt
git commit -m "docs: add an optional experiment"
git remote add origin ../selective07.git
git push origin main experiment
cd ..
mkdir observer07
cd observer07
git init -b main
git remote add origin ../selective07.git
git fetch origin \
  refs/heads/experiment:refs/remotes/origin/experiment
```



### 观察取得的入口，并显式创建工作分支

```bash
git show-ref
if git show-ref --verify --quiet refs/remotes/origin/main; then
  echo "Unexpected remote main observation" >&2
  exit 1
fi
git show origin/experiment:optional.txt
git switch -c study --track origin/experiment
test -f optional.txt
test "$(git branch --show-current)" = study
```


观察者取得了 experiment 对应对象和远程跟踪入口，却没有因该命令自动创建 origin/main。随后创建 study 才形成可检出的本地工作分支。取得一条分支的历史，可能同时取得其祖先对象；引用范围与对象依赖范围也应分别理解。

### 删除与清理同样需要明确范围
服务器分支删除后，本地远程跟踪入口可能继续保留，直到按相应规则清理。清理远程跟踪引用通常不等于删除自己的本地工作分支。涉及标签、镜像配置或自定义映射时，清理范围还可能不同，执行前应查询配置并预览影响。

## 协议、服务与平台的分工
### 传输协议解决访问路径
本地路径、SSH 和 HTTPS 等方式提供不同连接与认证条件。它们不改变提交对象和父关系的基本含义，但会影响权限、代理、凭据管理与服务部署。学习协议时应先确认访问对象，再检查连接层问题，不要把网络失败误判为历史损坏。

裸仓库常用于接收与提供仓库数据，因为它不具有普通检出工作区。一个本地裸仓库可以帮助理解交换机制，但不等于已经具备完整托管平台：账号管理、评审、审计、备份和规则仍需要其他服务与运维措施。

### 只读发现与写入操作应区分
`ls-remote` 可以用于观察服务器公开的引用，而不先建立完整克隆。它给出的只是查询时可见的入口，仍受权限与服务器设置约束。推送则尝试更新服务器引用，需要相应授权并满足服务器规则。

实际接入新平台时，先核对地址与只读访问，再进行明确目标的写入，更容易定位问题。课程演练中使用自己的 fork 和任务分支，可以让协作记录保持清楚；不应把作者教材仓库的默认分支当作所有学生共享的实验草稿区。
