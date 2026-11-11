# .git管理目录与关联工作树

工作文件保存正在编辑的项目内容，Git管理目录保存对象、引用、索引和本地记录。普通仓库常在项目根目录使用.git目录；关联工作树的.git通常是指向工作树专属管理目录的文本文件。因此，应通过Git查询路径，不能只凭名称猜测或手工移动内部文件。

[可编辑目录图](../../assets/git-repository-layout.drawio) · [完整可运行实验](./examples/repository-layout.sh)

## 先区分数据的职责

| 路径或内容 | 职责与边界 |
|---|---|
| HEAD | 当前工作树的位置；通常是符号引用，也可能直接保存提交标识 |
| config | 本地仓库配置；工作树配置还要结合实际启用条件 |
| index | 二进制候选索引，保存路径、模式、对象标识及阶段 |
| objects | 松散或打包对象；pack索引与候选index是不同数据 |
| refs、packed-refs | files后端的引用保存方式；引用可读取不证明目标对象齐全 |
| logs | 本地引用变化记录，不是永久恢复保证 |
| FETCH_HEAD、ORIG_HEAD | 由相关操作更新的辅助记录，不能无条件作为当前目标 |
| info/exclude | 本地排除规则，不代替项目共享的忽略文件 |
| hooks | 默认钩子位置；实际路径可能由core.hooksPath配置改变 |
| commondir | 关联管理目录与公共目录的关系记录 |

示例固定SHA-1对象格式和files引用后端，目的是使观察条件明确。较早版本可能不支持相应选项，应先确认本机Git。实际仓库也可能使用其他对象格式或reftable引用后端。不要把以下目录布局当作所有版本与所有后端的固定磁盘协议。

## 在独立目录中观察

下面的命令按顺序在同一专用练习目录执行。先预测对象、名称和候选，再读取输出；自动运行版本含额外断言。

### 建立管理数据观察仓库

```bash
mkdir layout09
cd layout09
git init -b main --object-format=sha1 --ref-format=files
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Repository layout\n' > notes.txt
git add notes.txt
git commit -m "docs: establish a layout observation baseline"
git tag -a layout-v1 -m "Layout observation baseline"
```

建立实际提交和附注标签，确保后续查询有真实对象与名称。身份配置只作用于本示例仓库。

### 查询实际管理路径并读取可解释字段

```bash
git rev-parse --git-dir
git rev-parse --git-common-dir
git rev-parse --git-path HEAD
git rev-parse --git-path index
cat "$(git rev-parse --git-path HEAD)"
git ls-files --stage
git cat-file -p HEAD
```

分别查询Git管理目录、公共目录和指定文件路径。返回值可能是相对路径，解释时要保留当前目录条件。

### 验证磁盘编辑不自动更新候选

```bash
INDEX_BLOB=$(git rev-parse :notes.txt)
printf 'Unstaged detail\n' >> notes.txt
test "$(git rev-parse :notes.txt)" = "$INDEX_BLOB"
git diff -- notes.txt
git show :notes.txt
git restore --worktree -- notes.txt
```

工作文件修改以后，索引仍保存先前选定的内容。二进制索引不能用普通文本编辑器当作配置文件修改。

### 打包引用后核对逻辑名称

```bash
LAYOUT_TIP=$(git rev-parse main)
git pack-refs --all
git show-ref --verify refs/heads/main
test "$(git rev-parse main)" = "$LAYOUT_TIP"
git for-each-ref --format='%(refname) %(objectname)' refs/heads refs/tags
```

打包引用后，引用仍应解析到原目标；不存在同名松散文件不能直接推出引用已删除。

### 观察关联工作树的gitdir与公共目录

```bash
git worktree add -b inspect-layout ../layout09-linked
cat ../layout09-linked/.git
git -C ../layout09-linked rev-parse --git-dir
git -C ../layout09-linked rev-parse --git-common-dir
git -C ../layout09-linked rev-parse --git-path index
git worktree remove ../layout09-linked
test -z "$(git status --porcelain)"
cd ..
```

关联工作树拥有自己的HEAD和索引，并共享公共对象与多数引用。核对两侧路径后清理示例工作树，再返回起始目录。

## 验收

核对根提交数量、标签解析、索引的DIRC文件头、打包引用与工作树清理结果。实验通过只支持这些路径和状态关系，不应据此手工修复未知损坏。诊断真实仓库时，先保全目录，再查询对象、引用及外部依赖。
