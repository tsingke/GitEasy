# 工作区、索引与提交：辅导材料

## 忽略规则：从项目习惯到可验证模式
### 先区分共享规则与个人例外
项目产生的构建目录、临时日志和中间结果，往往需要所有协作者共同忽略，适合写入版本化的 `.gitignore`。某位成员自己的编辑器缓存或本地试验文件，则可能更适合使用本地排除机制。选择位置的依据是规则是否属于项目共同约定，而不是哪个文件更容易找到。

规则只影响相关未跟踪内容的发现和选择，不会抹去历史。对已经跟踪的文件，即使后来匹配忽略规则，仍应按正常差异审阅。若文件不应继续出现在后续版本，应另行改变跟踪状态，并说明是否仍需保留本地内容。

### 目录规则、通配符与反向规则
忽略模式并不等同于终端的任意路径展开。根目录锚定、目录结尾斜杠、通配符和反向规则各有含义。多级规则还会受位置与优先关系影响，应使用实际路径验证。特别是父目录已经被排除时，不能简单依靠对子路径的一条反向规则取得预期效果（参见仓库根目录的参考资料）。

一个常见需求是忽略输出目录里的全部生成物，却保留一份手写说明。与其猜测复杂模式，不如先明确目录本身是否允许遍历，再排除其内容并保留说明。下面的独立实验采用这种组织方式。


### 保留输出说明，忽略生成结果

```bash
mkdir ignore03
cd ignore03
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
mkdir build
cat > .gitignore <<'EOF'
/build/*
!/build/README.md
*.tmp
EOF
printf '# Build output directory\n' > build/README.md
printf 'generated data\n' > build/result.bin
printf 'temporary notes\n' > scratch.tmp
git check-ignore -v build/result.bin scratch.tmp
if git check-ignore -q build/README.md; then exit 1; fi
git status --short --untracked-files=all
```


`check-ignore -v` 帮助定位命中的规则来源和行号，适合解释“为什么这个文件没有出现”。对保留文件的查询则应不再报告被忽略。读者应同时检查发现列表，确保规则没有无意排除需要提交的资料。


### 形成明确的资料版本并核对跟踪范围

```bash
git add .gitignore build/README.md
git commit -m "chore: document and filter generated output"
git ls-files
test "$(git ls-files | wc -l | tr -d ' ')" = 2
test -z "$(git status --porcelain)"
test -f build/result.bin
```


状态干净时，生成结果仍可以存在于磁盘。由此可见，干净状态不能解释为“目录里只有 Git 保存的文件”。同样，忽略规则也不是删除规则；实际清理工作应另行确认范围，不能直接把所有被忽略内容都当作可丢弃资料。

### 为什么不宜随手强制加入文件
强制暂存可以突破普通忽略选择，但应有明确理由。例如确需跟踪一个示例文件，而现有规则过宽，可能应该修正规则，而不是让每位成员反复使用强制选项。否则项目规则与实际行为长期不一致，会增加新成员困惑。

如果文件属于凭据、个人设置或不可公开数据，强制加入更不是解决“看不到文件”的方法。应先判断文件性质，再选择合适保存位置。技术上能加入，不能推出项目上应该加入。

### 规则审阅与迁移任务
请为一个包含源资料、临时图像和构建产物的课程仓库编写最小规则，并提供三个正例与三个反例。每个例子说明文件是否应被跟踪，以及实际查询是否符合判断。规则变化应单独审阅，特别留意宽泛通配符是否误排除新教材材料。

验收时从新克隆开始生成一份输出，确认共享规则仍然有效；再检查本地个人例外是否需要另行配置。共享规则和个人环境分别验证，才能形成可交接的项目约定。
